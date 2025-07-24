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
    /// Quiz endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class QuizController : ControllerBase
    {
        private readonly AIService _aiService;
        private readonly ILogger<QuizController> _logger;
        public QuizController(AIService aiService, ILogger<QuizController> logger)
        {
            _aiService = aiService;
            _logger = logger;
        }

        /// <summary>
        /// Generate a quiz for a topic and difficulty
        /// </summary>
        [HttpPost("generate")]
        public async Task<IActionResult> GenerateQuiz([FromBody] QuizRequest req)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            if (string.IsNullOrWhiteSpace(req.Topic) || string.IsNullOrWhiteSpace(req.Difficulty))
                return BadRequest(new { error = "Topic and difficulty are required." });
            var quiz = await _aiService.GenerateQuizAsync(req.Topic, req.Difficulty);
            _logger.LogInformation("Quiz generated for topic {Topic}, difficulty {Difficulty}", req.Topic, req.Difficulty);
            return Ok(new QuizDto { Questions = quiz is List<string> qList ? qList : new List<string>() });
        }

        /// <summary>
        /// Submit quiz answers for evaluation
        /// </summary>
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitQuiz([FromBody] QuizSubmission req)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { error = "Invalid input.", details = ModelState });
            var result = await _aiService.EvaluateQuizAsync(req);
            _logger.LogInformation("Quiz submitted for user {UserId}", req.UserId);
            return Ok(result);
        }
    }

    /// <summary>
    /// DTO for quiz generation request
    /// </summary>
    public class QuizRequest
    {
        [Required]
        public string Topic { get; set; }
        [Required]
        public string Difficulty { get; set; }
    }

    /// <summary>
    /// DTO for quiz output
    /// </summary>
    public class QuizDto
    {
        public List<string> Questions { get; set; }
    }

    /// <summary>
    /// DTO for quiz submission
    /// </summary>
    public class QuizSubmission
    {
        [Required]
        public string UserId { get; set; }
        [Required]
        public List<UserAnswer> Answers { get; set; }
        [Required]
        public string Difficulty { get; set; }
    }

    /// <summary>
    /// DTO for user answer
    /// </summary>
    public class UserAnswer
    {
        [Required]
        public string Question { get; set; }
        [Required]
        public string Selected { get; set; }
        public string Correct { get; set; }
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
    }
} 