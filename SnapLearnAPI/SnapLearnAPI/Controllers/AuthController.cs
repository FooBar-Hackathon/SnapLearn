using Microsoft.AspNetCore.Identity;
using SnapLearnAPI.Models.Requests;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Services;
using SnapLearnAPI.Models;
using SnapLearnAPI.Utils;
using SnapLearnAPI.Contexts;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.Extensions.Logging;
using System.ComponentModel.DataAnnotations;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace SnapLearnAPI.Controllers
{
    /// <summary>
    /// Authentication endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly JwtService _jwtService;
        private readonly UserManager<User> _userManager;
        private readonly SnapLearnDbContext _snapLearnContext;
        private readonly ILogger<AuthController> _logger;

        public AuthController(JwtService jwtService, UserManager<User> userManager, SnapLearnDbContext snapLearnContext, ILogger<AuthController> logger)
        {
            _jwtService = jwtService;
            _userManager = userManager;
            _snapLearnContext = snapLearnContext;
            _logger = logger;
        }

        /// <summary>
        /// Register a new user
        /// </summary>
        [HttpPost("Register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            if (!Validation.IsValidEmail(request.Email))
                return BadRequest(new { error = "Please enter a valid email." });

            // Check if username exists
            var existedUsername = await _snapLearnContext.Users.AsNoTracking().FirstOrDefaultAsync(u => u.UserName == request.UserName || u.Email == request.Email);
            if (existedUsername != null)
                return BadRequest(new { error = "Username/Email already in use." });

            var user = new User
            {
                Id = Guid.NewGuid(),
                Email = request.Email,
                UserName = request.UserName,
                Exp = 0,
                Level = 0,
            };

            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
            {
                _logger.LogWarning("User registration failed for {Email}", request.Email);
                return BadRequest(new { error = "Registration failed.", details = result.Errors });
            }

            // Save user config
            var userConfig = new UserConfig
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                Language = request.Language,
                AiPersonality = "friendly"
            };
            _snapLearnContext.UserConfigs.Add(userConfig);
            await _snapLearnContext.SaveChangesAsync();

            var deviceId = Guid.NewGuid();
            _logger.LogInformation("User registered: {Email}", request.Email);
            return Ok(new { user.UserName });
        }

        /// <summary>
        /// Login a user
        /// </summary>
        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            var user = await _snapLearnContext.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
                return BadRequest(new { error = $"User with the email {request.Email} not found!" });

            // Use ASP.NET Identity's password verification
            var dbUser = await _userManager.FindByEmailAsync(request.Email);
            var isValid = dbUser != null && await _userManager.CheckPasswordAsync(dbUser, request.Password);
            if (!isValid)
                return Unauthorized(new { error = "Invalid password." });

            var deviceId = Guid.NewGuid().ToString();
            var token = _jwtService.GenerateToken(user.Id, deviceId);
            var refreshToken = _jwtService.GenerateRefreshToken();
            var refreshTokenEntity = new RefreshToken
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                Token = refreshToken,
                Expiration = DateTime.UtcNow.AddDays(Constants.REFRESH_TOKEN_EXPIRATION_DAYS),
                DeviceId = deviceId
            };
            _snapLearnContext.RefreshTokens.Add(refreshTokenEntity);
            await _snapLearnContext.SaveChangesAsync();
            _logger.LogInformation("User logged in: {Email}", request.Email);
            return Ok(new { token, refreshToken, deviceId });
        }

        /// <summary>
        /// Refresh JWT token
        /// </summary>
        [HttpPost("RefreshToken")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            var principal = _jwtService.ValidateToken(request.Token);
            if (principal == null)
                return Unauthorized(new { error = "Invalid token." });
            var userIdClaim = principal.FindFirst(JwtRegisteredClaimNames.Sub);
            if (userIdClaim == null)
                return Unauthorized(new { error = "Invalid token." });
            var userId = Guid.Parse(userIdClaim.Value);
            var refreshToken = await _snapLearnContext.RefreshTokens.FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken && rt.UserId == userId && rt.DeviceId == request.DeviceId);
            if (refreshToken == null || refreshToken.Expiration < DateTime.UtcNow)
                return Unauthorized(new { error = "Invalid or expired refresh token." });
            var newToken = _jwtService.GenerateToken(userId, request.DeviceId);
            var newRefreshToken = _jwtService.GenerateRefreshToken();
            refreshToken.Token = newRefreshToken;
            refreshToken.Expiration = DateTime.UtcNow.AddDays(Constants.REFRESH_TOKEN_EXPIRATION_DAYS);
            _snapLearnContext.RefreshTokens.Update(refreshToken);
            await _snapLearnContext.SaveChangesAsync();
            _logger.LogInformation("Token refreshed for userId {UserId}", userId);
            return Ok(new { token = newToken, refreshToken = newRefreshToken, deviceId = request.DeviceId });
        }

        /// <summary>
        /// Logout current user (all devices)
        /// </summary>
        [HttpPost("Logout")]
        public async Task<IActionResult> Logout()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized(new { error = "User not found." });
            var refreshTokens = await _snapLearnContext.RefreshTokens.Where(rt => rt.UserId == user.Id).ToListAsync();
            _snapLearnContext.RefreshTokens.RemoveRange(refreshTokens);
            await _snapLearnContext.SaveChangesAsync();
            _logger.LogInformation("User logged out: {UserId}", user.Id);
            return Ok(new { success = true });
        }

        /// <summary>
        /// Logout a specific device
        /// </summary>
        [HttpPost("LogoutDevice")]
        public async Task<IActionResult> LogoutDevice([FromBody] RefreshTokenRequest request)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized(new { error = "User not found." });
            var refreshToken = await _snapLearnContext.RefreshTokens.FirstOrDefaultAsync(rt => rt.UserId == user.Id && rt.DeviceId == request.DeviceId && rt.Token == request.RefreshToken);
            if (refreshToken == null)
                return NotFound(new { error = "Refresh token for this device not found." });
            _snapLearnContext.RefreshTokens.Remove(refreshToken);
            await _snapLearnContext.SaveChangesAsync();
            _logger.LogInformation("Device logged out for userId {UserId}", user.Id);
            return Ok(new { success = true });
        }

        /// <summary>
        /// Check if the current user's token is valid
        /// </summary>
        [HttpGet("check-token-validity")]
        public async Task<IActionResult> CheckTokenValidity()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized(new { error = "User not found." });
            var refreshTokens = await _snapLearnContext.RefreshTokens.Where(rt => rt.UserId == user.Id).ToListAsync();
            if (refreshTokens.Count == 0)
                return Unauthorized(new { error = "No valid refresh tokens found." });
            foreach (var token in refreshTokens)
            {
                if (token.Expiration > DateTime.UtcNow)
                {
                    return Ok(new { valid = true, token = token.Token });
                }
            }
            return Ok(new { valid = false });
        }
    }
}
