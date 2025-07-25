using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class Battle
    {
        [Key]
        public Guid Id { get; set; }
        public string Topic { get; set; }
        public string Difficulty { get; set; }
        public string Status { get; set; } // e.g. waiting, in_progress, finished
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public Guid? WinnerId { get; set; }
        public ICollection<BattlePlayer> Players { get; set; }
    }

    public class BattlePlayer
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("Battle")]
        public Guid BattleId { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        public int Score { get; set; }
        public bool IsReady { get; set; }
        public Battle Battle { get; set; }
        public User User { get; set; }
    }
} 