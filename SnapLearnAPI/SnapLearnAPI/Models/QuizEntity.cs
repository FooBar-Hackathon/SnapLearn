using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models
{
    public class QuizEntity
    {
        [Key]
        public Guid QuizId { get; set; }
        public string Topic { get; set; } = string.Empty;
        public string Difficulty { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string QuestionsJson { get; set; } = string.Empty;
    }
} 