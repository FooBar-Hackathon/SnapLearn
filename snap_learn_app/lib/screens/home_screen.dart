import 'package:flutter/material.dart';
import 'package:snap_learn_app/widgets/StatCard.dart';
import 'camera_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'battle_screen.dart';
import '../services/api_service.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  Map<String, dynamic>? _dashboard;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _HomeTab(
        dashboard: _dashboard,
        loading: _loading,
        error: _error,
        onRetry: _fetchDashboard,
      ),
      CameraScreen(),
      BattleScreen(),
      LeaderboardScreen(),
      ProfileScreen(),
    ];
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dashboard = await ApiService.getDashboardSummary();
      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Pass dashboard, loading, error to _HomeTab
    _pages[0] = _HomeTab(
      dashboard: _dashboard,
      loading: _loading,
      error: _error,
      onRetry: _fetchDashboard,
    );
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: PhysicalModel(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(32),
          shadowColor: theme.colorScheme.primary.withOpacity(0.18),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  selected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.sports_kabaddi,
                  label: 'Battle',
                  selected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.leaderboard,
                  label: 'Leaderboard',
                  selected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: _selectedIndex == 4,
                  onTap: () => _onItemTapped(4),
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: selected ? 32 : 26,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              if (selected)
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.labelSmall?.fontSize,
                  ),
                  child: Text(label),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final Map<String, dynamic>? dashboard;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  const _HomeTab({
    this.dashboard,
    required this.loading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(error!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      );
    }
    if (dashboard == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Please log in to see your dashboard.',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    // Parse dashboard fields
    final String userName = dashboard?['userName'] ?? '';
    final int level = dashboard?['level'] ?? 1;
    final double xp = (dashboard?['xp'] ?? 0).toDouble();
    final String? profilePic = dashboard?['profilePicPath'];
    final int streak3 = dashboard?['streak3'] ?? 0;
    final int streak6 = dashboard?['streak6'] ?? 0;
    final int streak8 = dashboard?['streak8'] ?? 0;
    final int winCount = dashboard?['winCount'] ?? 0;
    final double winRate = (dashboard?['winRate'] ?? 0).toDouble();
    final int quizzesTaken = dashboard?['quizzesTaken'] ?? 0;
    final int battlesPlayed = dashboard?['battlesPlayed'] ?? 0;
    final int longestStreak = dashboard?['longestStreak'] ?? 0;
    final int totalXP = dashboard?['totalXP'] ?? 0;
    final List quizzes = dashboard?['recentQuizzes'] ?? [];
    final List battles = dashboard?['recentBattles'] ?? [];
    final List badges =
        dashboard?['badges'] ??
        [
          {'icon': Icons.star, 'label': 'Starter'},
          {'icon': Icons.emoji_events, 'label': 'Winner'},
          {'icon': Icons.flash_on, 'label': 'Streak'},
        ];
    // XP for next level (3x per level)
    final double nextLevelXp =
        100 *
        (level == 1
            ? 1
            : List.generate(level, (i) => i).fold(1.0, (a, b) => a * 3));
    final double xpProgress = (xp / nextLevelXp).clamp(0.0, 1.0);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Banner/Carousel
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔥 Daily Challenge',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Complete a quiz and earn bonus XP!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Lottie.asset(
                    'assets/animations/xp_increase.json',
                    width: 60,
                    height: 60,
                    repeat: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickAction(
                  icon: Icons.quiz,
                  label: 'Quiz',
                  color: Colors.blue,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.sports_kabaddi,
                  label: 'Battle',
                  color: Colors.red,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.camera_alt_rounded,
                  label: 'Scan',
                  color: Colors.green,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.leaderboard,
                  label: 'Ranks',
                  color: Colors.amber,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Profile + Level + Badges
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                      ? NetworkImage(profilePic)
                      : null,
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  child: (profilePic == null || profilePic.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 32,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome,', style: theme.textTheme.labelLarge),
                      Text(
                        userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.military_tech,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Level $level',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badges
                Row(
                  children: badges
                      .map<Widget>(
                        (b) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Tooltip(
                            message: b['label'],
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.15),
                              child: Icon(
                                b['icon'] as IconData,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // XP Progress Bar with Lottie
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Positioned(
                  left: (xpProgress * MediaQuery.of(context).size.width * 0.7)
                      .clamp(0, MediaQuery.of(context).size.width - 40),
                  child: Lottie.asset(
                    'assets/animations/xp_increase.json',
                    width: 32,
                    height: 32,
                    repeat: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // More StatCards
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                children: [
                  const SizedBox(width: 4),
                  StatCard(
                    label: 'Streak 3',
                    value: streak3.toString(),
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  StatCard(
                    label: 'Streak 6',
                    value: streak6.toString(),
                    icon: Icons.whatshot,
                    color: Colors.red,
                  ),
                  StatCard(
                    label: 'Streak 8',
                    value: streak8.toString(),
                    icon: Icons.flash_on,
                    color: Colors.amber,
                  ),
                  StatCard(
                    label: 'Wins',
                    value: winCount.toString(),
                    icon: Icons.emoji_events,
                    color: Colors.green,
                  ),
                  StatCard(
                    label: 'Win Rate',
                    value: '${(winRate * 100).toStringAsFixed(1)}%',
                    icon: Icons.percent,
                    color: Colors.blue,
                  ),
                  StatCard(
                    label: 'Quizzes',
                    value: quizzesTaken.toString(),
                    icon: Icons.quiz,
                    color: Colors.purple,
                  ),
                  StatCard(
                    label: 'Battles',
                    value: battlesPlayed.toString(),
                    icon: Icons.sports_kabaddi,
                    color: Colors.redAccent,
                  ),
                  StatCard(
                    label: 'Longest Streak',
                    value: longestStreak.toString(),
                    icon: Icons.timeline,
                    color: Colors.teal,
                  ),
                  StatCard(
                    label: 'Total XP',
                    value: totalXP.toString(),
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Divider(thickness: 1, height: 24),
            // Recent Quizzes
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Quizzes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...quizzes.map<Widget>(
              (q) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Card(
                  color: theme.colorScheme.primary.withOpacity(0.07),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.quiz, color: theme.colorScheme.primary),
                    title: Text(
                      q['topic'] ?? '-',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Row(
                      children: [
                        Chip(
                          label: Text(q['difficulty'] ?? '-'),
                          backgroundColor: theme.colorScheme.secondary
                              .withOpacity(0.15),
                        ),
                        const SizedBox(width: 8),
                        Text('Score: ${q['score'] ?? '-'}'),
                      ],
                    ),
                    trailing: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(40, 36),
                      ),
                      child: const Text('Review'),
                    ),
                  ),
                ),
              ),
            ),
            if (quizzes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No recent quizzes found.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Divider(thickness: 1, height: 24),
            // Recent Battles
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Battles',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...battles.map<Widget>(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Card(
                  color: theme.colorScheme.secondary.withOpacity(0.07),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.sports_kabaddi,
                      color: theme.colorScheme.secondary,
                    ),
                    title: Text(
                      b['topic'] ?? '-',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Row(
                      children: [
                        Chip(
                          label: Text(b['result'] ?? '-'),
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.15),
                        ),
                        const SizedBox(width: 8),
                        Text('XP: ${b['xp'] ?? '-'}'),
                      ],
                    ),
                    trailing: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(40, 36),
                      ),
                      child: const Text('Review'),
                    ),
                  ),
                ),
              ),
            ),
            if (battles.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No recent battles.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic date;
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String dateStr = '';
    if (date != null) {
      try {
        final dt = DateTime.parse(date.toString());
        dateStr =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        dateStr = date.toString();
      }
    }
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: Text(dateStr, style: theme.textTheme.bodySmall),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
