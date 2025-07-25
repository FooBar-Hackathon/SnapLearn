using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SnapLearnAPI.Contexts;
using SnapLearnAPI.Models;
using SnapLearnAPI.Models.Requests;
using SnapLearnAPI.Services;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SnapLearnAPI.Controllers
{
    /// <summary>
    /// Battle endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class BattleController : ControllerBase
    {
        private readonly AIService _aiService;
        private readonly ILogger<BattleController> _logger;
        private readonly SnapLearnDbContext _db;
        public BattleController(AIService aiService, ILogger<BattleController> logger, SnapLearnDbContext db)
        {
            _aiService = aiService;
            _logger = logger;
            _db = db;
        }

        /// <summary>
        /// Start a new battle (generate quiz)
        /// </summary>
        //[HttpPost("start")]
        //public async Task<IActionResult> StartBattle([FromBody] BattleStartRequest req)
        //{
        //    if (!ModelState.IsValid)
        //        return BadRequest(new { error = "Invalid input.", details = ModelState });

        //    // Create battle in DB
        //    var battle = new Battle
        //    {
        //        Id = Guid.NewGuid(),
        //        Topic = req.Topic,
        //        Difficulty = req.Difficulty,
        //        Status = "waiting",
        //        StartTime = DateTime.UtcNow,
        //        Players = new List<BattlePlayer>()
        //    };
        //    var player = new BattlePlayer
        //    {
        //        Id = Guid.NewGuid(),
        //        BattleId = battle.Id,
        //        UserId = Guid.Parse(req.UserId),
        //        Score = 0,
        //        IsReady = false
        //    };
        //    battle.Players.Add(player);
        //    _db.Battles.Add(battle);
        //    _db.BattlePlayers.Add(player);
        //    await _db.SaveChangesAsync();

        //    // Generate quiz for the battle
        //    var quiz = await _aiService.GenerateQuizAsync(new QuizGenerationRequest {
        //        Topic = req.Topic,
        //        Difficulty = req.Difficulty,
        //        QuestionCount = 5 // or configurable
        //    });
        //    _logger.LogInformation("Battle started for user {UserId}, topic {Topic}, difficulty {Difficulty}", req.UserId, req.Topic, req.Difficulty);
        //    return Ok(new { battleId = battle.Id, quiz });
        //}

        /// <summary>
        /// Submit battle answers for evaluation
        /// </summary>
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitBattleAnswers([FromBody] BattleSubmission req)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var guid))
                return Unauthorized(new { error = "Invalid or missing user claim." });

            var result = await _aiService.EvaluateQuizAsync(new QuizSubmission {
                Answers = req.Answers,
                Difficulty = req.Difficulty
            });
            _logger.LogInformation("Battle answers submitted for user {UserId}", userIdClaim);
            return Ok(result);
        }

        /// <summary>
        /// Get the result of a battle (mocked)
        /// </summary>
        [HttpGet("result")]
        public async Task<IActionResult> GetBattleResult([FromQuery][Required] string battleId)
        {
            // In a real app, fetch and return battle result from DB
            _logger.LogInformation("Battle result fetched for battleId {BattleId}", battleId);
            return Ok(new { winner = "UserA", xp = 30 });
        }
    }

    /// <summary>
    /// DTO for battle start request
    /// </summary>
    public class BattleStartRequest
    {
        [Required]
        public string UserId { get; set; }
        [Required]
        public string Topic { get; set; }
        [Required]
        public string Difficulty { get; set; }
    }

    /// <summary>
    /// DTO for battle submission
    /// </summary>
    public class BattleSubmission
    {
        [Required]
        public string BattleId { get; set; }
        [Required]
        public List<UserAnswer> Answers { get; set; }
        [Required]
        public string Difficulty { get; set; }
    }
} 