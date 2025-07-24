using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace SnapLearnAPI.Models
{
    public class User: IdentityUser
    {
        public string? ProfilPath { get; set; }
        public float Exp { get; set; }
        public int Level { get; set; }
    }
}
