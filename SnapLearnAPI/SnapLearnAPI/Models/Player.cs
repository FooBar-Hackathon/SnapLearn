using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;

namespace SnapLearnAPI.Models
{
    public class Player
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        [ForeignKey("Object")]
        public Guid ObjectId { get; set; }
        [ForeignKey("Match")]
        public Guid MatchId { get; set; }
        [ForeignKey("Session")]
        public Guid SessionId { get; set; }
        public string Status { get; set; }
        // Navigation properties
        public User User { get; set; }
        public DetectedObject Object { get; set; }
        public Match Match { get; set; }
        public Session Session { get; set; }
        public ICollection<Point> Points { get; set; }
    }
} 