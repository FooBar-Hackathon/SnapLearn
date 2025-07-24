namespace SnapLearnAPI.Repositories
{
    public class RepositoryBase<T> where T : class
    {
        public RepositoryBase() { 
        
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            // Simulate async operation
            await Task.Delay(100);
            return new List<T>();
        }
    }
}
