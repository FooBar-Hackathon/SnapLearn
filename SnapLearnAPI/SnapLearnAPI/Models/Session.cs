using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;

namespace SnapLearnAPI.Models
{
    public class Session
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("Match")]
        public Guid MatchId { get; set; }
        public string Winner { get; set; }
        public string Status { get; set; }
        // Navigation properties
        public Match Match { get; set; }
        public ICollection<Player> Players { get; set; }
        public ICollection<Point> Points { get; set; }
    }
} 