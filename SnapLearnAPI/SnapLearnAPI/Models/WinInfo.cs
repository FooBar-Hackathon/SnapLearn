using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class WinInfo
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        public int Streak3 { get; set; }
        public int Streak6 { get; set; }
        public int Streak8 { get; set; }
        public int Count { get; set; }
        public float WinRate { get; set; }
        // Navigation property
        public User User { get; set; }
    }
} 