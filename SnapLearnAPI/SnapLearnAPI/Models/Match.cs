using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;

namespace SnapLearnAPI.Models
{
    public class Match
    {
        [Key]
        public Guid Id { get; set; }
        public string Name { get; set; }
        public int QuestionQuantity { get; set; }
        public int PlayerQuantity { get; set; }
        // Navigation properties
        public ICollection<Session> Sessions { get; set; }
        public ICollection<Player> Players { get; set; }
        public ICollection<LevelOption> LevelOptions { get; set; }
    }
} 