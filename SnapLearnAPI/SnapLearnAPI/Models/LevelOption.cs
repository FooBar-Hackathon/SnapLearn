using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class LevelOption
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("Match")]
        public Guid MatchId { get; set; }
        public string Name { get; set; }
        // Navigation property
        public Match Match { get; set; }
    }
} 