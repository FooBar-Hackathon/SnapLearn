using SnapLearnAPI.Controllers; // For QuizSubmission, UserAnswer, QuizResult
using SnapLearnAPI.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
//wow

namespace SnapLearnAPI.Services
{
    public class AIService
    {
        private readonly GeminiService _geminiService;

        public AIService(GeminiService geminiService)
        {
            _geminiService = geminiService;
        }

        public async Task<string> GeneratePromptAsync(List<DetectedObject> objects, string text)
        {
            var objectLabels = objects != null && objects.Count > 0
                ? string.Join(", ", objects.Select(o => o.Label))
                : "none";
            var prompt = $"Given these objects: [{objectLabels}] and this text: '{text}', generate a learning prompt or quiz question for a student.";
            return await _geminiService.GenerateContent(prompt);
        }

        public async Task<List<string>> GenerateFactsAsync(string topic)
        {
            var prompt = $"Give me 3 fun facts about {topic}. Return as a simple numbered list, no extra explanation.";
            var factsText = await _geminiService.GenerateContent(prompt);
            // Parse the facts into a list (split by newlines or numbers)
            var facts = factsText.Split('\n')
                .Select(f => f.TrimStart('1','2','3','.',' ','-')).Where(f => !string.IsNullOrWhiteSpace(f)).ToList();
            return facts;
        }

        /// <summary>
        /// Generate a quiz for a topic and difficulty
        /// </summary>
        public async Task<List<string>> GenerateQuizAsync(string topic, string difficulty)
        {
            // For hackathon/demo, mock 5 questions
            var questions = new List<string>
            {
                $"What is a key fact about {topic}?",
                $"Explain {topic} in simple terms.",
                $"How does {topic} relate to real life?",
                $"What is a common misconception about {topic}?",
                $"Why is {topic} important to learn?"
            };
            return await Task.FromResult(questions);
        }

        public async Task<QuizResult> EvaluateQuizAsync(QuizSubmission submission)
        {
            int correct = 0;
            foreach (var answer in submission.Answers)
            {
                if (answer.Selected == answer.Correct)
                    correct++;
            }
            return await Task.FromResult(new QuizResult
            {
                Correct = correct,
                Total = submission.Answers.Count,
                XP = correct * 10,
                Bonus = correct == submission.Answers.Count ? 10 : 0
            });
        }
    }
}
