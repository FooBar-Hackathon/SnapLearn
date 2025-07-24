using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models
{
    public class User: IdentityUser
    {
        [Key]
        public Guid Id { get; set; }
        public string? ProfilPath { get; set; }
        public float Exp { get; set; }
        public int Level { get; set; }
    }
}
