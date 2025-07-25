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
        public DbSet<Battle> Battles { get; set; }
        public DbSet<BattlePlayer> BattlePlayers { get; set; }
        public DbSet<QuizEntity> Quizzes { get; set; }

        public static async Task SeedDataAsync(SnapLearnDbContext db)
        {
            if (!db.Users.Any())
            {
                var user1 = new User { Id = Guid.NewGuid(), UserName = "alice", Email = "alice@example.com", Level = 2, Exp = 150 };
                var user2 = new User { Id = Guid.NewGuid(), UserName = "bob", Email = "bob@example.com", Level = 3, Exp = 300 };
                db.Users.AddRange(user1, user2);

                db.UserConfigs.AddRange(
                    new UserConfig { Id = Guid.NewGuid(), UserId = user1.Id, ProfilePicPath = "", Language = "en", AiPersonality = "friendly" },
                    new UserConfig { Id = Guid.NewGuid(), UserId = user2.Id, ProfilePicPath = "", Language = "es", AiPersonality = "strict" }
                );
            }

            if (!db.Quizzes.Any())
            {
                var quiz = new QuizEntity
                {
                    QuizId = Guid.NewGuid(),
                    Topic = "Mathematics",
                    Difficulty = "medium",
                    CreatedAt = DateTime.UtcNow,
                    QuestionsJson = System.Text.Json.JsonSerializer.Serialize(new List<QuizQuestion> {
                        new QuizQuestion {
                            Id = Guid.NewGuid(),
                            Question = "What is 2 + 2?",
                            Options = new List<string> { "3", "4", "5", "6" },
                            CorrectAnswer = "4",
                            Explanation = "2 + 2 = 4",
                            Points = 10,
                            Difficulty = "medium",
                            Topic = "Mathematics"
                        },
                        new QuizQuestion {
                            Id = Guid.NewGuid(),
                            Question = "What is the square root of 9?",
                            Options = new List<string> { "2", "3", "4", "5" },
                            CorrectAnswer = "3",
                            Explanation = "The square root of 9 is 3.",
                            Points = 10,
                            Difficulty = "medium",
                            Topic = "Mathematics"
                        }
                    })
                };
                db.Quizzes.Add(quiz);
            }

            await db.SaveChangesAsync();
        }
    }
}
