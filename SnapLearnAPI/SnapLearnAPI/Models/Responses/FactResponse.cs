namespace SnapLearnAPI.Models.Responses
{
    public class FactResponse
    {
        public string Summary { get; set; }
        public List<string> Facts { get; set; }
        public string Language { get; set; }
        public FactResponse()
        {
            Facts = new List<string>();
            Language = "en"; // Default to English
        }

    }
}
