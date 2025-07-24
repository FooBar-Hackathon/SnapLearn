using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class RefreshToken
    {
        [Key]
        public Guid Id { get; set; }

        [ForeignKey("User")]
        public Guid UserId { get; set; }
        
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
        public string DeviceId { get; set; } = string.Empty;
    }
}
