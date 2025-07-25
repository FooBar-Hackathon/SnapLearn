using Microsoft.AspNetCore.Mvc;
using SnapLearnAPI.Services;
using System.Threading.Tasks;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LearnController : ControllerBase
    {
        private readonly AIService _aiService;
        public LearnController(AIService aiService)
        {
            _aiService = aiService;
        }

        //[HttpGet("facts")]
        //public async Task<IActionResult> GetFacts([FromQuery] string topic)
        //{
        //    if (string.IsNullOrWhiteSpace(topic))
        //        return BadRequest("Topic is required.");
        //    var facts = await _aiService.GenerateFactsAsync(topic);
        //    return Ok(new { topic, facts });
        //}
    }
} 