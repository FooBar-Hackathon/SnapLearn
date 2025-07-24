using Microsoft.EntityFrameworkCore;
using SnapLearnAPI.Models;

namespace SnapLearnAPI.Contexts
{
    public class SnapLearnDbContext : DbContext
    {
        public SnapLearnDbContext(DbContextOptions<SnapLearnDbContext> options) : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Configure your entity mappings here
        }
        
        public DbSet<User> Users { get; set; }
        public DbSet<UserConfig> UserConfigs { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
    }
}
