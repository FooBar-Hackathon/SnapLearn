using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class UserConfig
    {
        public Guid Id { get; set; }

        [ForeignKey("User")]
        public Guid UserId { get; set; }
        [Required]
        public User User { get; set; }
        public string Language { get; set; } = "eng";

        public string AiPersonality { get; set; } = "friendly";

    }
}
