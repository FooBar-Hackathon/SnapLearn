using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace SnapLearnAPI.Contexts
{
    public class SnapLearnDbContextFactory : IDesignTimeDbContextFactory<SnapLearnDbContext>
    {
        public SnapLearnDbContext CreateDbContext(string[] args)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .Build();

            var optionsBuilder = new DbContextOptionsBuilder<SnapLearnDbContext>();
            optionsBuilder.UseNpgsql(config.GetConnectionString("DefaultConnection"));

            return new SnapLearnDbContext(optionsBuilder.Options);
        }
    }
} 