using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Contexts;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.ComponentModel.DataAnnotations;
using Microsoft.Extensions.Logging;
using System.Security.Claims;
using System.Collections.Generic;
using SnapLearnAPI.Models;

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
                userConfig = new Models.UserConfig { UserId = user.Id, AiPersonality = "Smart Teacher", Language = "eng", ProfilePicPath ="" };
                _db.UserConfigs.Add(userConfig);
            }
            userConfig.AiPersonality = req.AiPersonality;
            userConfig.Language = req.Language;
            await _db.SaveChangesAsync();
            _logger.LogInformation("Profile updated for userId {UserId}", userIdClaim);
            return Ok(new { success = true });
        }

        /// <summary>
        /// Get a dashboard summary for the current user
        /// </summary>
        [HttpGet("summary")]
        public async Task<IActionResult> GetDashboardSummary()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var guid))
                return Unauthorized(new { error = "Invalid or missing user claim." });

            var user = await _db.Users
                .AsNoTracking()
                .Include(u => u.UserConfigs)
                .FirstOrDefaultAsync(u => u.Id == guid);
            if (user == null)
                return NotFound(new { error = "User not found." });
            var userConfig = user.UserConfigs?.FirstOrDefault();

            // Recent quizzes
            var recentQuizzes = await _db.Quizzes
                .Where(q => q.QuestionsJson.Contains(user.UserName)) // TODO: Replace with real user association
                .OrderByDescending(q => q.CreatedAt)
                .Take(3)
                .Select(q => new QuizSummaryDto
                {
                    Topic = q.Topic,
                    Difficulty = q.Difficulty,
                    Date = q.CreatedAt
                })
                .ToListAsync();

            // Recent battles
            var recentBattles = await _db.Battles
                .Where(b => b.Players.Any(p => p.UserId == guid))
                .OrderByDescending(b => b.EndTime ?? b.StartTime)
                .Take(3)
                .Select(b => new BattleSummaryDto
                {
                    Topic = b.Topic,
                    Result = b.WinnerId == guid ? "Win" : (b.WinnerId == null ? "In Progress" : "Loss"),
                    Date = b.EndTime ?? b.StartTime
                })
                .ToListAsync();

            // Win streak info
            var winInfo = await _db.Set<WinInfo>().FirstOrDefaultAsync(w => w.UserId == guid);

            var summary = new DashboardSummaryDto
            {
                UserName = user.UserName,
                Xp = user.Exp,
                Level = user.Level,
                ProfilePicPath = userConfig?.ProfilePicPath,
                RecentQuizzes = recentQuizzes,
                RecentBattles = recentBattles,
                Streak3 = winInfo?.Streak3 ?? 0,
                Streak6 = winInfo?.Streak6 ?? 0,
                Streak8 = winInfo?.Streak8 ?? 0,
                WinCount = winInfo?.Count ?? 0,
                WinRate = winInfo?.WinRate ?? 0f
            };
            return Ok(summary);
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

    public class DashboardSummaryDto
    {
        public string UserName { get; set; }
        public float Xp { get; set; }
        public int Level { get; set; }
        public string ProfilePicPath { get; set; }
        public List<QuizSummaryDto> RecentQuizzes { get; set; }
        public List<BattleSummaryDto> RecentBattles { get; set; }
        public int Streak3 { get; set; }
        public int Streak6 { get; set; }
        public int Streak8 { get; set; }
        public int WinCount { get; set; }
        public float WinRate { get; set; }
    }
    public class QuizSummaryDto
    {
        public string Topic { get; set; }
        public string Difficulty { get; set; }
        public DateTime Date { get; set; }
    }
    public class BattleSummaryDto
    {
        public string Topic { get; set; }
        public string Result { get; set; }
        public DateTime? Date { get; set; }
    }
} 
