using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Services;
using SnapLearnAPI.Models.Requests;
using SnapLearnAPI.Models.Responses;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using System.ComponentModel.DataAnnotations;
using System;
using Swashbuckle.AspNetCore.Annotations;
using SnapLearnAPI.Contexts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace SnapLearnAPI.Controllers
{
    /// <summary>
    /// Quiz management and generation endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class QuizController : ControllerBase
    {
        private readonly AIService _aiService;
        private readonly ILogger<QuizController> _logger;
        private readonly SnapLearnDbContext _db;
        
        public QuizController(AIService aiService, ILogger<QuizController> logger, SnapLearnDbContext db)
        {
            _aiService = aiService;
            _logger = logger;
            _db = db;
        }

        /// <summary>
        /// Generate a comprehensive quiz with questions, multiple choice options, correct answers, and explanations
        /// </summary>
        /// <param name="request">Quiz generation parameters</param>
        /// <returns>Quiz with questions, options, answers, and explanations</returns>
        [HttpPost("generate")]
        [Authorize]
        public async Task<IActionResult> GenerateQuiz([FromBody] QuizGenerationRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
                
            if (string.IsNullOrWhiteSpace(request.Topic) || string.IsNullOrWhiteSpace(request.Difficulty))
                return BadRequest(new { error = "Topic and difficulty are required." });

            // Get user language from UserConfig
            var userId = User?.Identity?.Name;
            if (!string.IsNullOrEmpty(userId) && Guid.TryParse(userId, out var guid))
            {
                var userConfig = await _db.UserConfigs.FirstOrDefaultAsync(u => u.UserId == guid);
                if (userConfig != null && !string.IsNullOrWhiteSpace(userConfig.Language))
                    request.Language = userConfig.Language;
            }
            request.Language ??= "en";

            try
            {
                var quiz = await _aiService.GenerateQuizAsync(request); // Now returns QuizResponse
                _logger.LogInformation("Quiz generated for topic {Topic}, difficulty {Difficulty}, questions {QuestionCount}, language {Language}", 
                    request.Topic, request.Difficulty, request.QuestionCount, request.Language);
                
                return Ok(quiz); // Return the QuizResponse object directly
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating quiz for topic {Topic}", request.Topic);
                return StatusCode(500, new { error = "Failed to generate quiz. Please try again." });
            }
        }

        /// <summary>
        /// Submit quiz answers for evaluation and scoring
        /// </summary>
        /// <param name="submission">Quiz submission with user answers</param>
        /// <returns>Quiz results with score, XP, and bonus points</returns>
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitQuiz([FromBody] QuizSubmission submission)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var guid))
                return Unauthorized(new { error = "Invalid or missing user claim." });

            try
            {
                var result = await _aiService.EvaluateQuizAsync(submission);

                // Update user XP
                var user = await _db.Users.FindAsync(guid);
                if (user != null)
                {
                    user.Exp += result.XP + result.Bonus;
                    // Level-up logic
                    int nextLevel = user.Level + 1;
                    float requiredXp = 100f * (float)Math.Pow(3, user.Level);
                    while (user.Exp >= requiredXp)
                    {
                        user.Level++;
                        nextLevel = user.Level + 1;
                        requiredXp = 100f * (float)Math.Pow(3, user.Level);
                    }
                    await _db.SaveChangesAsync();
                }

                _logger.LogInformation("Quiz submitted for user {UserId}, score: {Correct}/{Total}, XP awarded: {XP}, Bonus: {Bonus}",
                    userIdClaim, result.Correct, result.Total, result.XP, result.Bonus);

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error evaluating quiz for user {UserId}", userIdClaim);
                return StatusCode(500, new { error = "Failed to evaluate quiz. Please try again." });
            }
        }

        /// <summary>
        /// Get fun facts about a specific topic
        /// </summary>
        /// <param name="topic">The topic to get facts about</param>
        /// <returns>List of interesting facts</returns>
        [HttpGet("facts/{topic}/{difficulty}")]
        [Authorize]
        public async Task<IActionResult> GetFacts([FromRoute] string topic, [FromRoute] string difficulty)
        {
            if (string.IsNullOrWhiteSpace(topic))
                return BadRequest(new { error = "Topic is required." });

            // Get user language from UserConfig
            var userId = User?.Identity?.Name;
            string language = "eng";
            if (!string.IsNullOrEmpty(userId) && Guid.TryParse(userId, out var guid))
            {
                var userConfig = await _db.UserConfigs.FirstOrDefaultAsync(u => u.UserId == guid);
                if (userConfig != null && !string.IsNullOrWhiteSpace(userConfig.Language))
                    language = userConfig.Language;
            }

            try
            {
                var facts = await _aiService.GenerateFactsAsync(topic, difficulty, language);
                _logger.LogInformation("Facts generated for topic {Topic} in language {Language}", topic, language);
                return Ok(new
                {
                    topic,
                    summary = facts.Summary,
                    facts = facts.Facts,
                    language = facts.Language
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating facts for topic {Topic}", topic);
                return StatusCode(500, new { error = "Failed to generate facts. Please try again." });
            }
        }
    }

    /// <summary>
    /// DTO for quiz submission
    /// </summary>
    public class QuizSubmission
    {
        [Required]
        public Guid QuizId { get; set; }
        [Required]
        public List<UserAnswer> Answers { get; set; } = new List<UserAnswer>();
        [Required]
        public string Difficulty { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO for user answer
    /// </summary>
    public class UserAnswer
    {
        [Required]
        public string Question { get; set; } = string.Empty;
        [Required]
        public string Selected { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO for quiz result
    /// </summary>
    public class QuizResult
    {
        public int Correct { get; set; }
        public int Total { get; set; }
        public int XP { get; set; }
        public int Bonus { get; set; }
        public float Percentage => Total > 0 ? (float)Correct / Total * 100 : 0;
        public string Grade => Percentage switch
        {
            >= 90 => "A",
            >= 80 => "B",
            >= 70 => "C",
            >= 60 => "D",
            _ => "F"
        };
    }
} 