using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models
{
    public class User : IdentityUser
    {
        [Key]
        public Guid Id { get; set; }
        public int Level { get; set; }
        public float Exp { get; set; }
        // Navigation properties
        public ICollection<UserConfig> UserConfigs { get; set; }
        public ICollection<WinInfo> WinInfos { get; set; }
        public ICollection<Player> Players { get; set; }
    }
}
