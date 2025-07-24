using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using SnapLearnAPI.Services;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.IO;
using Swashbuckle.AspNetCore.Annotations;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VisionController: ControllerBase
    {
        private readonly VisionService _visionService;
        private readonly AIService _aiService;

        public VisionController(VisionService visionService, AIService aiService)
        {
            _visionService = visionService;
            _aiService = aiService;
        }

        [HttpPost("detect-objects")]
        public async Task<IActionResult> DetectObjects(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            using var stream = file.OpenReadStream();
            var objects = await _visionService.DetectObjectsAsync(stream);
            return Ok(objects);
        }

   
        [HttpPost("extract-text")]
        public async Task<IActionResult> ExtractText(IFormFile file, string language = "eng")
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            using var stream = file.OpenReadStream();
            var text = await _visionService.ExtractTextAsync(stream, language);
            if (string.IsNullOrWhiteSpace(text))
                return Ok(new { text = "", message = "No text found." });
            return Ok(new { text });
        }

 
        [HttpPost("analyze")]
        public async Task<IActionResult> Analyze(IFormFile file, string language = "eng")
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            using var stream = file.OpenReadStream();
            // Copy stream for reuse
            using var ms1 = new MemoryStream();
            await stream.CopyToAsync(ms1);
            ms1.Position = 0;
            using var ms2 = new MemoryStream(ms1.ToArray());

            var objects = await _visionService.DetectObjectsAsync(ms1);
            var text = await _visionService.ExtractTextAsync(ms2, language);
            var prompt = await _aiService.GeneratePromptAsync(objects, text);
            return Ok(new { objects, text, prompt });
        }
    }
}
