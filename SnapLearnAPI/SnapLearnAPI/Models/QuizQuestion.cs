using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models
{
    public class QuizQuestion
    {
        [Key]
        public Guid Id { get; set; }
        public string Question { get; set; } = string.Empty;
        public List<string> Options { get; set; } = new List<string>();
        public string CorrectAnswer { get; set; } = string.Empty;
        public string Explanation { get; set; } = string.Empty;
        public string Difficulty { get; set; } = "medium";
        public string Topic { get; set; } = string.Empty;
        public int Points { get; set; } = 10;
    }
} 