using Newtonsoft.Json;
using System.Text;

namespace SnapLearnAPI.Services
{
    public class GeminiService
    {
        private readonly HttpClient _http;
        private readonly string _apiKey;
        private string ApiURL => $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={_apiKey}";

        public GeminiService(HttpClient http, IConfiguration config)
        {
            _http = http;
            _apiKey = config["Gemini:ApiKey"];
        }

        public async Task<string> GenerateJsonContent(string prompt)
        {
            var request = new
            {
                contents = new[] {
                    new {
                        parts = new[] {
                            new { text = prompt + "\nReturn only raw JSON. No markdown or code blocks." }
                        }
                    }
                },
                generationConfig = new { response_mime_type = "application/json" }
            };

            var httpRequest = new HttpRequestMessage(HttpMethod.Post, ApiURL);
            httpRequest.Content = new StringContent(JsonConvert.SerializeObject(request), Encoding.UTF8, "application/json");
            var response = await _http.SendAsync(httpRequest);
            var json = await response.Content.ReadAsStringAsync();
            dynamic parsed = JsonConvert.DeserializeObject(json);
            return parsed?.candidates?[0]?.content?.parts?[0]?.text ?? "No response";
        }

        public async Task<string> GenerateContent(string prompt)
        {
            var request = new
            {
                contents = new[] {
                    new {
                        parts = new[] {
                            new { text = prompt + "\nReturn only raw JSON. No markdown or code blocks." }
                        }
                    }
                }
            };

            var httpRequest = new HttpRequestMessage(HttpMethod.Post, ApiURL);
            httpRequest.Content = new StringContent(JsonConvert.SerializeObject(request), Encoding.UTF8, "application/json");
            var response = await _http.SendAsync(httpRequest);
            var json = await response.Content.ReadAsStringAsync();
            dynamic parsed = JsonConvert.DeserializeObject(json);
            return parsed?.candidates?[0]?.content?.parts?[0]?.text ?? "No response";
        }
    }
} 