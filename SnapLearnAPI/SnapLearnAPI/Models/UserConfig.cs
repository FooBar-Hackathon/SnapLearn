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
        public string ProfilePicPath { get; set; }
        public string AiPersonality { get; set; }
        public string Language { get; set; }
        // Navigation property
        public User User { get; set; }
    }
}
