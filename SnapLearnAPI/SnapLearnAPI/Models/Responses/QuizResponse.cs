using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models.Responses
{
    public class QuizResponse
    {
        public Guid QuizId { get; set; }
        public string Topic { get; set; } = string.Empty;
        public string Difficulty { get; set; } = string.Empty;
        public List<QuizQuestion> Questions { get; set; } = new List<QuizQuestion>();
        public int TotalPoints { get; set; }
        public int TimeLimit { get; set; } = 300; // 5 minutes default
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
} 