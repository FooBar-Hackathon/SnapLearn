using SnapLearnAPI.Contexts;
using SnapLearnAPI.Controllers; // For QuizSubmission, UserAnswer, QuizResult
using SnapLearnAPI.Models;
using SnapLearnAPI.Models.Requests;
using SnapLearnAPI.Models.Responses;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
//wow

namespace SnapLearnAPI.Services
{
    public class AIService
    {
        private readonly GeminiService _geminiService;
        private readonly SnapLearnDbContext _db; // Added for DB operations

        public AIService(GeminiService geminiService, SnapLearnDbContext db)
        {
            _geminiService = geminiService;
            _db = db; // Initialize DB context
        }

        public async Task<string> GeneratePromptAsync(List<DetectedObject> objects, string text)
        {
            var objectLabels = objects != null && objects.Count > 0
                ? string.Join(", ", objects.Select(o => o.Label))
                : "none";
            var prompt = $"Given these objects: [{objectLabels}] and this text: '{text}', generate a learning prompt or quiz question for a student.";
            return await _geminiService.GenerateContent(prompt);
        }

        public async Task<FactResponse> GenerateFactsAsync(string topic, string difficulty, string language = "en")
        {
            var prompt = $"Topic: {topic} (if mouse = Computer Mouse if not ignore), generate a learning prompt or quiz question for a student. Also provide a brief summary and 3 fun facts. Difficulty: {difficulty} Respond in JSON: {{ \"summary\": \"...\", \"facts\": [\"...\", \"...\", \"...\"], \"language\": \"{language}\" }}";
            var geminiResponse = await _geminiService.GenerateJsonContent(prompt);

            try
            {
                using var doc = JsonDocument.Parse(geminiResponse);

                // If the root is an array, get the first object
                var root = doc.RootElement;
                if (root.ValueKind == JsonValueKind.Array && root.GetArrayLength() > 0)
                    root = root[0];

                var factResponse = new FactResponse();
                if (root.TryGetProperty("summary", out var summaryElem))
                    factResponse.Summary = summaryElem.GetString() ?? string.Empty;
                if (root.TryGetProperty("facts", out var factsElem) && factsElem.ValueKind == JsonValueKind.Array)
                {
                    foreach (var f in factsElem.EnumerateArray())
                        if (f.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(f.GetString()))
                            factResponse.Facts.Add(f.GetString());
                }
                if (root.TryGetProperty("language", out var langElem))
                    factResponse.Language = langElem.GetString() ?? language;
                else
                    factResponse.Language = language;
                return factResponse;
            }
            catch
            {
                // Fallback: just return a basic response
                return new FactResponse
                {
                    Summary = $"Topic: {topic}.", // Include topic in summary
                    Facts = new List<string> { "No facts available.", "No facts available.", "No facts available." },
                    Language = language
                };
            }
        }


        /// <summary>
        /// Generate a quiz for a topic and difficulty
        /// </summary>
        //public async Task<List<string>> GenerateQuizAsync(string topic, string difficulty)
        //{
        //    // For hackathon/demo, mock 5 questions
        //    var questions = new List<string>
        //    {
        //        $"What is a key fact about {topic}?",
        //        $"Explain {topic} in simple terms.",
        //        $"How does {topic} relate to real life?",
        //        $"What is a common misconception about {topic}?",
        //        $"Why is {topic} important to learn?"
        //    };
        //    return await Task.FromResult(questions);
        //}

        public async Task<QuizResult> EvaluateQuizAsync(QuizSubmission submission)
        {
            var quizEntity = await _db.Quizzes.FindAsync(submission.QuizId);
            if (quizEntity == null)
                throw new Exception("Quiz not found or expired.");
            var questions = JsonSerializer.Deserialize<List<QuizQuestion>>(quizEntity.QuestionsJson);
            int correct = 0;
            foreach (var answer in submission.Answers)
            {
                var original = questions.FirstOrDefault(q => q.Question == answer.Question);
                if (original != null)
                {
                    // Map the user's selected letter to the actual option text
                    var selectedIndex = answer.Selected.Length == 1 ? (int)answer.Selected[0] - 65 : -1; // 'A'->0, 'B'->1, etc.
                    var selectedText = (selectedIndex >= 0 && selectedIndex < original.Options.Count)
                        ? original.Options[selectedIndex]
                        : null;
                    if (selectedText != null && selectedText == original.CorrectAnswer)
                        correct++;
                }
            }
            return await Task.FromResult(new QuizResult
            {
                Correct = correct,
                Total = submission.Answers.Count,
                XP = correct * 10,
                Bonus = correct == submission.Answers.Count ? 10 : 0
            });
        }
        public async Task<QuizResponse> GenerateQuizAsync(QuizGenerationRequest request)
        {
            var prompt = $"Generate a quiz with {request.QuestionCount} questions about \"{request.Topic} (if mouse = Computer Mouse if not ignore)\". " +
                         $"Difficulty: {request.Difficulty}. " +
                         $"Language: {request.Language ?? "en"}. " +
                         "Respond ONLY with a JSON array of objects, each with: " +
                         "question (string), options (array of 4 strings), correctAnswer (string, must match one of the options), explanation (string), points (int, default 10).";

            var response = await _geminiService.GenerateJsonContent(prompt);

            List<QuizQuestion> questions = new();
            try
            {
                using var doc = JsonDocument.Parse(response);
                if (doc.RootElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var item in doc.RootElement.EnumerateArray())
                    {
                        var q = new QuizQuestion
                        {
                            Question = item.GetProperty("question").GetString() ?? string.Empty,
                            Options = item.GetProperty("options").EnumerateArray().Select(x => x.GetString() ?? string.Empty).ToList(),
                            CorrectAnswer = item.GetProperty("correctAnswer").GetString() ?? string.Empty,
                            Explanation = item.GetProperty("explanation").GetString() ?? string.Empty,
                            Points = item.TryGetProperty("points", out var pts) ? (pts.ValueKind == JsonValueKind.Number ? pts.GetInt32() : 10) : 10,
                            Difficulty = request.Difficulty,
                            Topic = request.Topic
                        };
                        // Ensure options has at least 2 and correctAnswer is in options
                        if (q.Options.Count >= 2 && q.Options.Contains(q.CorrectAnswer))
                            questions.Add(q);
                    }
                }
            }
            catch
            {
                // Fallback: mock questions
                for (int i = 1; i <= request.QuestionCount; i++)
                {
                    questions.Add(new QuizQuestion
                    {
                        Question = $"[Fallback] Question {i} about {request.Topic}.",
                        Options = new List<string> { "A", "B", "C", "D" },
                        CorrectAnswer = "A",
                        Explanation = "This is a fallback explanation.",
                        Points = 10,
                        Difficulty = request.Difficulty,
                        Topic = request.Topic
                    });
                }
            }

            // Fallback if Gemini returns no valid questions
            if (questions.Count == 0)
            {
                for (int i = 1; i <= request.QuestionCount; i++)
                {
                    questions.Add(new QuizQuestion
                    {
                        Question = $"[Fallback] Question {i} about {request.Topic}.",
                        Options = new List<string> { "A", "B", "C", "D" },
                        CorrectAnswer = "A",
                        Explanation = "This is a fallback explanation.",
                        Points = 10,
                        Difficulty = request.Difficulty,
                        Topic = request.Topic
                    });
                }
            }

            var quiz = new QuizResponse
            {
                QuizId = Guid.NewGuid(),
                Topic = request.Topic,
                Difficulty = request.Difficulty,
                Questions = questions,
                TotalPoints = questions.Sum(q => q.Points),
                TimeLimit = 300,
                CreatedAt = DateTime.UtcNow
            };
            // Store in DB
            var quizEntity = new QuizEntity
            {
                QuizId = quiz.QuizId,
                Topic = quiz.Topic,
                Difficulty = quiz.Difficulty,
                CreatedAt = quiz.CreatedAt,
                QuestionsJson = JsonSerializer.Serialize(quiz.Questions)
            };
            _db.Quizzes.Add(quizEntity);
            await _db.SaveChangesAsync();
            return quiz;
        }
    }
}
