using Microsoft.AspNetCore.Identity;
using SnapLearnAPI.Models.Requests;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Services;
using SnapLearnAPI.Models;
using SnapLearnAPI.Utils;
using SnapLearnAPI.Contexts;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly JwtService _jwtService;
        private readonly UserManager<User> _userManager;
        private readonly SnapLearnDbContext _snapLearnContext;

        public AuthController(JwtService jwtService, UserManager<User> userManager, SnapLearnDbContext snapLearnContext)
        {
            _jwtService = jwtService;
            _userManager = userManager;
            _snapLearnContext = snapLearnContext;
        }

        [HttpPost("Register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            if (!Validation.IsValidEmail(request.Email))
            {
                return BadRequest("Please enter a valid email.");
            }

            // Check if username exists
            var existedUsername = await _snapLearnContext.Users
                .FirstOrDefaultAsync(u => u.UserName == request.UserName);
            if (existedUsername != null)
            {
                return BadRequest("Username already exists.");
            }

            // Check if email exists
            var existedEmail = await _snapLearnContext.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);
            if (existedEmail != null)
            {
                return BadRequest("Email already exists.");
            }

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
                return BadRequest(result.Errors);
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

            return Ok(new { user.UserName });
        }

        [HttpPost("Login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            var user = await _snapLearnContext.Users.FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest($"User with the email {request.Email} not found!");

            // Use ASP.NET Identity's password verification
            var isValid = await _userManager.CheckPasswordAsync(user, request.Password);

            if (!isValid)
                return Unauthorized("Invalid password.");

            // Accept DeviceId from request or generate new
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

            return Ok(new { token, refreshToken, deviceId });
        }

        [HttpPost("RefreshToken")]
        public async Task<IActionResult> RefreshToken(RefreshTokenRequest request)
        {
            var principal = _jwtService.ValidateToken(request.Token);
            if (principal == null)
                return Unauthorized("Invalid token.");

            var userIdClaim = principal.FindFirst(JwtRegisteredClaimNames.Sub);

            if (userIdClaim == null)
                return Unauthorized("Invalid token.");

            var userId = Guid.Parse(userIdClaim.Value);
            var refreshToken = await _snapLearnContext.RefreshTokens
                .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken && rt.UserId == userId && rt.DeviceId == request.DeviceId);

            if (refreshToken == null || refreshToken.Expiration < DateTime.UtcNow)
                return Unauthorized("Invalid or expired refresh token.");

            var newToken = _jwtService.GenerateToken(userId, request.DeviceId);
            var newRefreshToken = _jwtService.GenerateRefreshToken();
            refreshToken.Token = newRefreshToken;
            refreshToken.Expiration = DateTime.UtcNow.AddDays(Constants.REFRESH_TOKEN_EXPIRATION_DAYS);
            _snapLearnContext.RefreshTokens.Update(refreshToken);

            await _snapLearnContext.SaveChangesAsync();

            return Ok(new { token = newToken, refreshToken = newRefreshToken, deviceId = request.DeviceId });
        }

        [HttpPost("Logout")]
        public async Task<IActionResult> Logout()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized("User not found.");

            var refreshTokens = await _snapLearnContext.RefreshTokens
                .Where(rt => rt.UserId == user.Id).ToListAsync();

            _snapLearnContext.RefreshTokens.RemoveRange(refreshTokens);
            await _snapLearnContext.SaveChangesAsync();

            return Ok("Logged out successfully.");
        }

        [HttpPost("LogoutDevice")]
        public async Task<IActionResult> LogoutDevice([FromBody] RefreshTokenRequest request)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized("User not found.");

            var refreshToken = await _snapLearnContext.RefreshTokens
                .FirstOrDefaultAsync(rt => rt.UserId == user.Id && rt.DeviceId == request.DeviceId && rt.Token == request.RefreshToken);

            if (refreshToken == null)
                return NotFound("Refresh token for this device not found.");

            _snapLearnContext.RefreshTokens.Remove(refreshToken);
            await _snapLearnContext.SaveChangesAsync();

            return Ok("Device logged out successfully.");
        }

        [HttpGet("check-token-validity")]
        public async Task<IActionResult> CheckTokenValidity()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized("User not found.");

            var refreshTokens = await _snapLearnContext.RefreshTokens
                .Where(rt => rt.UserId == user.Id).ToListAsync();

            if (refreshTokens.Count == 0)
                return Unauthorized("No valid refresh tokens found.");

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
