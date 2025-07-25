using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Contexts;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.ComponentModel.DataAnnotations;
using Microsoft.Extensions.Logging;
using System.Security.Claims;

namespace SnapLearnAPI.Controllers
{
    /// <summary>
    /// Profile management endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class ProfileController : ControllerBase
    {
        private readonly SnapLearnDbContext _db;
        private readonly ILogger<ProfileController> _logger;
        public ProfileController(SnapLearnDbContext db, ILogger<ProfileController> logger)
        {
            _db = db;
            _logger = logger;
        }

        /// <summary>
        /// Get the current user's profile (from JWT)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var guid))
                return Unauthorized(new { error = "Invalid or missing user claim." });

            var user = await _db.Users
                .AsNoTracking()
                .Include(u => u.UserConfigs)
                .FirstOrDefaultAsync(u => u.Id == guid);
            if (user == null)
            {
                _logger.LogWarning("Profile not found for userId {UserId}", userIdClaim);
                return NotFound(new { error = "User not found." });
            }
            var userConfig = user.UserConfigs?.FirstOrDefault();
            var dto = new ProfileDto
            {
                UserName = user.UserName,
                Xp = user.Exp,
                Email = user.Email,
                Level = user.Level,
                ProfilePicPath = userConfig?.ProfilePicPath,
                AiPersonality = userConfig?.AiPersonality,
                Language = userConfig?.Language
            };
            return Ok(dto);
        }

        /// <summary>
        /// Update the current user's profile (from JWT)
        /// </summary>
        [HttpPost("update")]
        public async Task<IActionResult> UpdateProfile([FromBody] ProfileUpdateRequest req)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var guid))
                return Unauthorized(new { error = "Invalid or missing user claim." });

            var user = await _db.Users.Include(u => u.UserConfigs).FirstOrDefaultAsync(u => u.Id == guid);
            if (user == null) return NotFound(new { error = "User not found." });
            var userConfig = user.UserConfigs?.FirstOrDefault();
            if (userConfig == null)
            {
                userConfig = new Models.UserConfig { UserId = user.Id };
                _db.UserConfigs.Add(userConfig);
            }
            userConfig.AiPersonality = req.AiPersonality;
            userConfig.Language = req.Language;
            await _db.SaveChangesAsync();
            _logger.LogInformation("Profile updated for userId {UserId}", userIdClaim);
            return Ok(new { success = true });
        }
    }

    /// <summary>
    /// DTO for profile output
    /// </summary>
    public class ProfileDto
    {
        public string UserName { get; set; }
        public float Xp { get; set; }
        public int Level { get; set; }
        public string Email { get; set; }
        public string ProfilePicPath { get; set; }
        public string AiPersonality { get; set; }
        public string Language { get; set; }
    }

    /// <summary>
    /// DTO for profile update
    /// </summary>
    public class ProfileUpdateRequest
    {
        // [Required] // No longer needed, userId comes from JWT
        // public string UserId { get; set; }
        public string AiPersonality { get; set; }
        public string Language { get; set; }
    }
} 
