using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SnapLearnAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        // In-memory chat storage for demo
        private static readonly List<ChatMessage> Messages = new List<ChatMessage>();

        [HttpPost("send")]
        public IActionResult SendMessage([FromBody] ChatMessage req)
        {
            Messages.Add(new ChatMessage {
                MatchId = req.MatchId,
                UserId = req.UserId,
                Message = req.Message
            });
            return Ok();
        }

        [HttpGet("history")]
        public IActionResult GetChatHistory([FromQuery] string matchId)
        {
            var msgs = Messages.Where(m => m.MatchId == matchId).ToList();
            return Ok(msgs);
        }
    }

    public class ChatMessage
    {
        public string MatchId { get; set; }
        public string UserId { get; set; }
        public string Message { get; set; }
    }
} 