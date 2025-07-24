using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Contexts;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace SnapLearnAPI.Controllers
{
    /// <summary>
    /// Leaderboard endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class LeaderboardController : ControllerBase
    {
        private readonly SnapLearnDbContext _db;
        private readonly ILogger<LeaderboardController> _logger;
        public LeaderboardController(SnapLearnDbContext db, ILogger<LeaderboardController> logger)
        {
            _db = db;
            _logger = logger;
        }

        /// <summary>
        /// Get the top users in the leaderboard (paginated)
        /// </summary>
        /// <param name="page">Page number (default 1)</param>
        /// <param name="pageSize">Page size (default 10)</param>
        [HttpGet]
        public async Task<IActionResult> GetLeaderboard([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            if (page < 1 || pageSize < 1 || pageSize > 100)
                return BadRequest(new { error = "Invalid page or pageSize." });
            var query = _db.Users
                .AsNoTracking()
                .OrderByDescending(u => u.Exp)
                .Select(u => new LeaderboardUserDto
                {
                    UserName = u.UserName,
                    Exp = u.Exp,
                    Level = u.Level
                });
            var total = await query.CountAsync();
            var users = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
            _logger.LogInformation("Leaderboard fetched: page {Page}, size {PageSize}", page, pageSize);
            return Ok(new { total, page, pageSize, users });
        }
    }

    /// <summary>
    /// DTO for leaderboard user
    /// </summary>
    public class LeaderboardUserDto
    {
        public string UserName { get; set; }
        public float Exp { get; set; }
        public int Level { get; set; }
    }
} 