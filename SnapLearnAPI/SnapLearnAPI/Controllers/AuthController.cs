using Microsoft.AspNetCore.Identity;
using SnapLearnAPI.Models.Requests;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Services;
using SnapLearnAPI.Models;
using SnapLearnAPI.Utils;
using SnapLearnAPI.Contexts;
using Microsoft.EntityFrameworkCore;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly JwtService _jwtService;
        private readonly UserManager<User> _userManager;
        private readonly SnapLearnContext snapLearnContext;
        public AuthController(JwtService jwtService, UserManager<User> userManager)
        {
            _jwtService = jwtService;
            _userManager = userManager;
        }

        [HttpPost("Register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            if (!Validation.IsValidEmail(request.Email))
            {
                return BadRequest("Please enter a valid email.");
            }

            // Check if username exists
            var existedUsername = await snapLearnContext.Users
                .FirstOrDefaultAsync(u => u.UserName == request.UserName);
            if (existedUsername != null)
            {
                return BadRequest("Username already exists.");
            }

            // Check if email exists
            var existedEmail = await snapLearnContext.Users
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
                Language = request.Language
            };
            snapLearnContext.UserConfigs.Add(userConfig);
            await snapLearnContext.SaveChangesAsync();

            var deviceId = Guid.NewGuid();

            return Ok(new { user.UserName });
        }

        [HttpPost("Login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            var user = await snapLearnContext.Users.FindAsync(request.Email);

            if (user == null)
            {
                return BadRequest($"User with the email {request.Email} not found!");
            }

            var isValid = Validation.VerifyPassword(request.Password, user.PasswordHash);

            if (!isValid) {
                return Unauthorized("Invalid password.");
            }

            var deviceId = Guid.NewGuid().ToString();
            var token = _jwtService.GenerateToken(user.Id, deviceId);

        }


    }
}
