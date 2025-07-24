using Microsoft.AspNetCore.Mvc;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VisionController
    {
        [HttpPost("analyze-image")]
        public async Task<IActionResult> AnalyzeImage(IFormFile imageFile)
        {
            
            return Ok("Hello World");
        }
    }
}
