using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Models;
using SnapLearnAPI.Repositories;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserRepository _userRepository;
        private readonly ILogger<UserController> _logger;
        private readonly UserManager<User> _userManager;

        public UserController(UserRepository userRepository, UserManager<User> userManager, ILogger<UserController> logger)
        {
            _logger = logger;
            _userManager = userManager;
            _userRepository = userRepository;
        }

        [HttpGet("user-profile")]
        public async Task<IActionResult> GetUserProfile()
        {

            var currentUser = await _userManager.GetUserAsync(User);

            var userProfile = await _userRepository.GetUserProfileAsync(currentUser.Id);
            
            if (userProfile == null)
            {
                return NotFound("User profile not found.");
            }

            return Ok(new { userProfile.Id, userProfile.UserName, userProfile.Email, userProfile.ProfilPath, userProfile.Exp, userProfile.Level });
        }



    }
}
