import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _users = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
  final int _pageSize = 10;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/Leaderboard?page=$_page&pageSize=$_pageSize',
      );
      final response = await ApiService.get(url);
      setState(() {
        _users = response['users'] ?? [];
        _total = response['total'] ?? 0;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _fetchLeaderboard,
        child: _loading
            ? ListView.builder(
                itemCount: _pageSize,
                itemBuilder: (_, i) => _LeaderboardSkeleton(isWide: isWide),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _fetchLeaderboard,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _users.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_people,
                      color: theme.colorScheme.primary,
                      size: 54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No leaderboard data yet!',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (ctx, i) {
                  final user = _users[i];
                  final rank = (_page - 1) * _pageSize + i + 1;
                  return _LeaderboardTile(
                    rank: rank,
                    user: user,
                    isWide: isWide,
                  );
                },
              ),
      ),
      floatingActionButton: _page * _pageSize < _total
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _page++);
                _fetchLeaderboard();
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('More'),
            )
          : null,
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final dynamic user;
  final bool isWide;
  const _LeaderboardTile({
    required this.rank,
    required this.user,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [Colors.amber, Colors.grey, Colors.brown];
    final isTop3 = rank <= 3;
    return Card(
      color: isTop3
          ? colors[rank - 1].withOpacity(0.15)
          : theme.colorScheme.surfaceContainerHighest,
      elevation: isTop3 ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.symmetric(horizontal: isWide ? 48 : 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isTop3
                  ? colors[rank - 1]
                  : theme.colorScheme.primary,
              radius: isWide ? 28 : 22,
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Icon(
              Icons.person,
              color: theme.colorScheme.primary,
              size: isWide ? 36 : 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['userName'] ?? '-',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'XP: ${user['exp'] ?? '-'}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.military_tech, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Lvl ${user['level'] ?? '-'}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isTop3)
              Icon(
                Icons.emoji_events,
                color: colors[rank - 1],
                size: isWide ? 36 : 28,
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardSkeleton extends StatelessWidget {
  final bool isWide;
  const _LeaderboardSkeleton({required this.isWide});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 48 : 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: isWide ? 56 : 44,
              height: isWide ? 56 : 44,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 18),
            Container(
              width: isWide ? 36 : 28,
              height: isWide ? 36 : 28,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 16, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(width: 120, height: 12, color: Colors.grey[200]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
