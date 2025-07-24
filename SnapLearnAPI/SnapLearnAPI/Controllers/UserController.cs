using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Contexts;
using SnapLearnAPI.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.ComponentModel.DataAnnotations;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace SnapLearnAPI.Controllers
{
    /// <summary>
    /// User profile endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly SnapLearnDbContext _snapLearnContext;
        private readonly ILogger<UserController> _logger;

        public UserController(SnapLearnDbContext snapLearnContext, UserManager<User> userManager, ILogger<UserController> logger)
        {
            _snapLearnContext = snapLearnContext;
            _userManager = userManager;
            _logger = logger;
        }

        /// <summary>
        /// Get the current user's profile
        /// </summary>
        [HttpGet("user-profile")]
        public async Task<IActionResult> GetUserProfile()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
            {
                _logger.LogWarning("User not found for current context");
                return NotFound(new { error = "User profile not found." });
            }
            var userProfile = await _snapLearnContext.Users
                .AsNoTracking()
                .Include(u => u.UserConfigs)
                .FirstOrDefaultAsync(u => u.Id == currentUser.Id);
            if (userProfile == null)
            {
                _logger.LogWarning("User profile not found for userId {UserId}", currentUser.Id);
                return NotFound(new { error = "User profile not found." });
            }
            var userConfig = userProfile.UserConfigs?.FirstOrDefault();
            var dto = new UserProfileDto
            {
                Id = userProfile.Id,
                UserName = userProfile.UserName,
                Email = userProfile.Email,
                ProfilePicPath = userConfig?.ProfilePicPath,
                Exp = userProfile.Exp,
                Level = userProfile.Level
            };
            return Ok(dto);
        }
    }

    /// <summary>
    /// DTO for user profile output
    /// </summary>
    public class UserProfileDto
    {
        public Guid Id { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string ProfilePicPath { get; set; }
        public float Exp { get; set; }
        public int Level { get; set; }
    }
}
