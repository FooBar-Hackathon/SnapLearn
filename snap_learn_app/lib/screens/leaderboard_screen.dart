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
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/Leaderboard?page=$_page&pageSize=$_pageSize',
      );
      final response = await ApiService.get(url);
      if (!mounted) return;
      setState(() {
        _users = response['users'] ?? [];
        _total = response['total'] ?? 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeaderboard,
        child: _loading
            ? ListView.builder(
                itemCount: _pageSize + 1,
                itemBuilder: (ctx, i) => i == 0
                    ? _LeaderboardHeader()
                    : _LeaderboardSkeleton(isWide: isWide),
              )
            : _error != null
            ? ListView(
                children: [
                  _LeaderboardHeader(),
                  const SizedBox(height: 32),
                  Center(
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
                  ),
                ],
              )
            : _users.isEmpty
            ? ListView(
                children: [
                  _LeaderboardHeader(),
                  const SizedBox(height: 32),
                  Center(
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
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _users.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0) return _LeaderboardHeader();
                  final user = _users[i - 1];
                  final rank = (_page - 1) * _pageSize + i;
                  return _SimpleLeaderboardCard(
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

class _LeaderboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, color: theme.colorScheme.primary, size: 48),
          const SizedBox(height: 8),
          Text(
            'Leaderboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Climb the ranks by earning XP and leveling up!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SimpleLeaderboardCard extends StatelessWidget {
  final int rank;
  final dynamic user;
  final bool isWide;
  const _SimpleLeaderboardCard({
    required this.rank,
    required this.user,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [Colors.amber, Colors.grey, Colors.brown];
    final isTop3 = rank <= 3;
    final trophyIcon = isTop3
        ? Icon(Icons.emoji_events, color: colors[rank - 1], size: 28)
        : null;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 64 : 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isTop3 ? 4 : 1,
      child: ListTile(
        leading: CircleAvatar(
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
        title: Row(
          children: [
            Icon(Icons.person, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                user['userName'] ?? '-',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trophyIcon != null) ...[const SizedBox(width: 8), trophyIcon],
          ],
        ),
        subtitle: Row(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class _LeaderboardSkeleton extends StatelessWidget {
  final bool isWide;
  const _LeaderboardSkeleton({required this.isWide});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 64 : 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: ListTile(
        leading: Container(
          width: isWide ? 56 : 44,
          height: isWide ? 56 : 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
        ),
        title: Container(width: 80, height: 16, color: Colors.grey[300]),
        subtitle: Container(width: 120, height: 12, color: Colors.grey[200]),
      ),
    );
  }
}
