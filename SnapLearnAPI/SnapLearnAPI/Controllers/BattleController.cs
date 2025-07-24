using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Services;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using System.ComponentModel.DataAnnotations;
using System;

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
        public BattleController(AIService aiService, ILogger<BattleController> logger)
        {
            _aiService = aiService;
            _logger = logger;
        }

        /// <summary>
        /// Start a new battle (generate quiz)
        /// </summary>
        [HttpPost("start")]
        public async Task<IActionResult> StartBattle([FromBody] BattleStartRequest req)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            var quiz = await _aiService.GenerateQuizAsync(req.Topic, req.Difficulty);
            _logger.LogInformation("Battle started for user {UserId}, topic {Topic}, difficulty {Difficulty}", req.UserId, req.Topic, req.Difficulty);
            return Ok(new { battleId = Guid.NewGuid().ToString(), quiz });
        }

        /// <summary>
        /// Submit battle answers for evaluation
        /// </summary>
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitBattleAnswers([FromBody] BattleSubmission req)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            var result = await _aiService.EvaluateQuizAsync(new QuizSubmission {
                UserId = req.UserId,
                Answers = req.Answers,
                Difficulty = req.Difficulty
            });
            _logger.LogInformation("Battle answers submitted for user {UserId}", req.UserId);
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
        public string UserId { get; set; }
        [Required]
        public List<UserAnswer> Answers { get; set; }
        [Required]
        public string Difficulty { get; set; }
    }
} 