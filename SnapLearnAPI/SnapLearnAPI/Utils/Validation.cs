using System.Security.Cryptography;
using System.Text;

namespace SnapLearnAPI.Utils
{
    public static class Validation
    {
        public static bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private static string HashPassword(string password)
        {
            using var sha = SHA256.Create();
            var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
        public static bool VerifyPassword(string password, string hash)
        {
            return HashPassword(password) == hash;
        }

    }
}
