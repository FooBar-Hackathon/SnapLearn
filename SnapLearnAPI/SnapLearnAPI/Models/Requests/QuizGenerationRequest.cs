using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models.Requests
{
    public class QuizGenerationRequest
    {
        [Required]
        public string Topic { get; set; } = string.Empty;
        
        [Required]
        public string Difficulty { get; set; } = "medium";
        
        [Range(1, 20)]
        public int QuestionCount { get; set; } = 5;
        
        public string? Context { get; set; }
        
        public string? Language { get; set; } = "en";
    }
} 