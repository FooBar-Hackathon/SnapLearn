using Microsoft.EntityFrameworkCore;
using SnapLearnAPI.Models;

namespace SnapLearnAPI.Contexts
{
    public class SnapLearnContext: DbContext
    {
        public SnapLearnContext(DbContextOptions<SnapLearnContext> options) : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Configure your entity mappings here
        }
        // Define DbSets for your entities
        // public DbSet<YourEntity> YourEntities { get; set; }
        // Add more DbSets as needed

        public DbSet<User> Users { get; set; }
        public DbSet<UserConfig> UserConfigs { get; set; }
    }
}
