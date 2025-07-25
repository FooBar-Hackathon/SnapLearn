using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using SnapLearnAPI.Services;
using SnapLearnAPI.Contexts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VisionController: ControllerBase
    {
        private readonly VisionService _visionService;
        private readonly AIService _aiService;
        private readonly SnapLearnDbContext _db;

        public VisionController(VisionService visionService, AIService aiService, SnapLearnDbContext db)
        {
            _visionService = visionService;
            _aiService = aiService;
            _db = db;
        }

        [HttpPost("detect-objects")]
        public async Task<IActionResult> DetectObjects(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            using var stream = file.OpenReadStream();
            var objects = await _visionService.DetectObjectsAsync(stream);
            return Ok(objects);
        }

   
        [HttpPost("extract-text")]
        public async Task<IActionResult> ExtractText(IFormFile file, string language = "eng")
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            using var stream = file.OpenReadStream();
            var text = await _visionService.ExtractTextAsync(stream, language);
            if (string.IsNullOrWhiteSpace(text))
                return Ok(new { text = "", summary = "", message = "No text found." });

            string summary = "";
            try
            {
                // Use AIService to summarize the text for a title/description
                string prompt = $"Summarize the following text into a short, human-friendly title or description.\nText: {text}\nSummary:";
                summary = await _aiService.GeneratePromptAsync(null, prompt);
                if (!string.IsNullOrWhiteSpace(summary))
                {
                    // Clean up summary if needed
                    summary = summary.Trim().Replace("\n", " ");
                }
            }
            catch
            {
                // Fallback: use first line or first 10 words
                var words = text.Split(new[] { ' ', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
                summary = string.Join(" ", words.Take(10));
                if (text.Contains('\n'))
                    summary = text.Split('\n')[0];
            }
            return Ok(new { text, summary });
        }

 
        [HttpPost("analyze")]
        [Authorize]
        public async Task<IActionResult> Analyze(IFormFile file, string language = "eng")
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            // Read the image into a single byte array
            using var stream = file.OpenReadStream();
            using var ms = new MemoryStream();
            await stream.CopyToAsync(ms);
            var imageBytes = ms.ToArray();

            // Detect objects and draw in one pass
            var (objects, drawnImageStream) = _visionService.DetectAndDrawCombined(new MemoryStream(imageBytes));

            // OCR in parallel
            var ocrTask = _visionService.ExtractTextAsync(new MemoryStream(imageBytes), language);
            var text = await ocrTask;

            // Get user config for personality and language
            string personality = "friendly";
            string userLang = language;
            var userId = User?.Identity?.Name;
            if (!string.IsNullOrEmpty(userId) && Guid.TryParse(userId, out var guid))
            {
                var userConfig = await _db.UserConfigs.FirstOrDefaultAsync(u => u.UserId == guid);
                if (userConfig != null)
                {
                    if (!string.IsNullOrWhiteSpace(userConfig.AiPersonality))
                        personality = userConfig.AiPersonality;
                    if (!string.IsNullOrWhiteSpace(userConfig.Language))
                        userLang = userConfig.Language;
                }
            }

            // Build structured prompt
            string objectName = objects.FirstOrDefault()?.Label ?? "object";
            string prompt = $@"You are a {personality} smart teacher. Object: {objectName}
1. Give 3 interesting facts about it.
2. Make 3 multiple choice questions with 1 correct and 2 incorrect answers.
Output all facts, questions, and answers in {userLang}.
{{
  ""facts"": [""fact1"", ""fact2"", ""fact3""],
  ""quizzes"": [
    {{
      ""question"": ""Question text"",
      ""choices"": [""choice1"", ""choice2"", ""choice3""],
      ""answer"": ""correct answer""
    }}
  ]
}}";

            // Get facts and quizzes from Gemini
            var geminiResponse = await _aiService.GeneratePromptAsync(objects ,prompt);
            // Parse the response as JSON, robustly
            List<string> facts = new();
            List<object> quizzes = new();
            try
            {
                using var doc = System.Text.Json.JsonDocument.Parse(geminiResponse);
                if (doc.RootElement.TryGetProperty("facts", out var factsElem) && factsElem.ValueKind == System.Text.Json.JsonValueKind.Array)
                {
                    foreach (var f in factsElem.EnumerateArray())
                        if (f.ValueKind == System.Text.Json.JsonValueKind.String && !string.IsNullOrWhiteSpace(f.GetString()))
                            facts.Add(f.GetString());
                }
                if (doc.RootElement.TryGetProperty("quizzes", out var quizzesElem) && quizzesElem.ValueKind == System.Text.Json.JsonValueKind.Array)
                {
                    foreach (var q in quizzesElem.EnumerateArray())
                    {
                        var quizObj = new {
                            question = q.GetProperty("question").GetString(),
                            choices = q.GetProperty("choices").EnumerateArray().Select(c => c.GetString()).Where(s => !string.IsNullOrWhiteSpace(s)).ToList(),
                            answer = q.GetProperty("answer").GetString()
                        };
                        if (!string.IsNullOrWhiteSpace(quizObj.question) && quizObj.choices.Count >= 2 && !string.IsNullOrWhiteSpace(quizObj.answer))
                            quizzes.Add(quizObj);
                    }
                }
            }
            catch { /* fallback to empty lists if parsing fails */ }

            var imageBytesOut = drawnImageStream.ToArray();
            return Ok(new { objects, text, facts, quizzes, image = Convert.ToBase64String(imageBytesOut) });
        }
    }
}
