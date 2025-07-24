namespace SnapLearnAPI.Models.Requests
{
    public class RegisterRequest
    {
        public required string Email { get; set; }
        public required string UserName { get; set; }
        public required string Password { get; set; }
        public required string Language { get; set; }
    }
}
