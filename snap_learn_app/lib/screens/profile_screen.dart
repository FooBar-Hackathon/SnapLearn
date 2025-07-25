import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/quiz/level_up_animation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;
  bool _editing = false;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String? _language;
  String? _aiPersonality;
  int? _previousLevel;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ApiService.getProfile();
      if (profile != null) {
        _updateProfileData(profile);
      } else {
        setState(() {
          _error = 'Failed to load profile.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _updateProfileData(Map<String, dynamic> profile) {
    final allowedLanguages = ['eng', 'ind', 'jpn', 'chi_sim', 'chi_tra'];
    final allowedPersonalities = [
      'friendly',
      'serious',
      'funny',
      'motivational',
    ];

    _usernameController.text = profile['userName'] ?? '';
    _language = allowedLanguages.contains(profile['language'])
        ? profile['language']
        : allowedLanguages.first;
    _aiPersonality = allowedPersonalities.contains(profile['aiPersonality'])
        ? profile['aiPersonality']
        : allowedPersonalities.first;

    int? newLevel = profile['level'] is int
        ? profile['level']
        : int.tryParse(profile['level']?.toString() ?? '');
    final oldLevel = _previousLevel ?? newLevel;

    setState(() {
      _profile = profile;
      _loading = false;
      _previousLevel = newLevel;
    });

    if (newLevel != null && oldLevel != null && newLevel > oldLevel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LevelUpAnimation(newLevel: newLevel),
        );
      });
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ApiService.getProfile();
      if (profile != null) {
        _updateProfileData(profile);
      } else {
        setState(() {
          _error = 'Failed to load profile.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _editing = true);
    try {
      await ApiService.updateProfile(
        userName: _usernameController.text,
        language: _language!,
        aiPersonality: _aiPersonality!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _fetchProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: \\${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _editing = false);
      }
    }
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _profile?['email'] ?? 'user@example.com',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            Icons.star,
            'XP',
            _profile?['xp']?.toString() ?? '0',
            Colors.amber,
          ),
          _buildStatItem(
            theme,
            Icons.military_tech,
            'Level',
            _profile?['level']?.toString() ?? '1',
            Colors.green,
          ),
          _buildStatItem(
            theme,
            Icons.photo_camera,
            'Snaps',
            _profile?['snapCount']?.toString() ?? '0',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a username' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _language,
          decoration: InputDecoration(
            labelText: 'Language',
            prefixIcon: Icon(
              Icons.language,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: 'eng', child: Text('English')),
            DropdownMenuItem(value: 'ind', child: Text('Indonesian')),
            DropdownMenuItem(value: 'jpn', child: Text('Japanese')),
            DropdownMenuItem(
              value: 'chi_sim',
              child: Text('Chinese (Simplified)'),
            ),
            DropdownMenuItem(
              value: 'chi_tra',
              child: Text('Chinese (Traditional)'),
            ),
          ],
          onChanged: (value) => setState(() => _language = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _aiPersonality,
          decoration: InputDecoration(
            labelText: 'AI Personality',
            prefixIcon: Icon(
              Icons.smart_toy,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
            DropdownMenuItem(value: 'serious', child: Text('Serious')),
            DropdownMenuItem(value: 'funny', child: Text('Funny')),
            DropdownMenuItem(
              value: 'motivational',
              child: Text('Motivational'),
            ),
          ],
          onChanged: (value) => setState(() => _aiPersonality = value),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        FilledButton(
          onPressed: _editing ? null : _saveProfile,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _editing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Text('Save Changes'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            await ApiService.logout();
            if (!mounted) return;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: theme.colorScheme.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Logout',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _fetchProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loadProfile,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileHeader(theme),
                    const SizedBox(height: 32),
                    _buildStatsRow(theme),
                    const SizedBox(height: 32),
                    _buildFormFields(theme),
                    const SizedBox(height: 32),
                    _buildActionButtons(theme),
                  ],
                ),
              ),
            ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
