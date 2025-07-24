using SnapLearnAPI.Contexts;
using SnapLearnAPI.Models;

namespace SnapLearnAPI.Repositories
{
    public class UserRepository
    {
        public SnapLearnContext _context;

        public UserRepository(SnapLearnContext context)
        {
            _context = context;
        }   
        
        public async Task<User?> GetUserProfileAsync(Guid? id)
        {
            if (id == null)
            {
                return null;
            }

            var user = await _context.Users.FindAsync(id);            
            return user;
        }
    }
}
