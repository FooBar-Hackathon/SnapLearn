using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Contexts;
using SnapLearnAPI.Models;
using SnapLearnAPI.Repositories;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly ILogger<UserController> _logger;
        private readonly UserManager<User> _userManager;
        private readonly SnapLearnContext _snapLearnContext;

        public UserController(SnapLearnContext snapLearnContext,UserManager<User> userManager, ILogger<UserController> logger)
        {
            _snapLearnContext = snapLearnContext;
            _userManager = userManager;
            _logger = logger;
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
