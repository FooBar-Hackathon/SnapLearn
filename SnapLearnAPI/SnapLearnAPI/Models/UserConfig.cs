using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class UserConfig
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        public required string ProfilePicPath { get; set; } = "";
        public required string AiPersonality { get; set; } = "Smart Teacher";
        public required string Language { get; set; } = "ENG";
        // Navigation property
        public User User { get; set; }
    }
}
