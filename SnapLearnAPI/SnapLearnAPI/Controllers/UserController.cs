using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Contexts;
using SnapLearnAPI.Models;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly SnapLearnDbContext _snapLearnContext;

        public UserController(SnapLearnDbContext snapLearnContext,UserManager<User> userManager)
        {
            _snapLearnContext = snapLearnContext;
            _userManager = userManager;
        }

        [HttpGet("user-profile")]
        public async Task<IActionResult> GetUserProfile()
        {

            var currentUser = await _userManager.GetUserAsync(User);

            var userProfile = await _snapLearnContext.Users.FindAsync(currentUser.Id);
            
            if (userProfile == null)
            {
                return NotFound("User profile not found.");
            }

            return Ok(new { userProfile.Id, userProfile.UserName, userProfile.Email, userProfile.ProfilPath, userProfile.Exp, userProfile.Level });
        }

    }
}
