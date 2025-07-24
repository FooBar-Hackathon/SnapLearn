namespace SnapLearnAPI.Models.Requests
{
    public class RefreshTokenRequest
    {
        public required string Token { get; set; }
        public required string RefreshToken { get; set; }
        public required string DeviceId { get; set; }
    }
}
