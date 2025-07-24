using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class Point
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("Session")]
        public Guid SessionId { get; set; }
        [ForeignKey("Player")]
        public Guid PlayerId { get; set; }
        public int RightAnswers { get; set; }
        public int SpeedPosition { get; set; }
        public float XpGained { get; set; }
        // Navigation properties
        public Session Session { get; set; }
        public Player Player { get; set; }
    }
} 