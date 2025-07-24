import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  String? _username;
  String? _language;
  String? _aiPersonality;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/Profile?userId=YOUR_USER_ID',
      );
      final response = await ApiService.get(url);
      setState(() {
        _profile = response;
        _username = response['userName'] ?? '';
        _language = response['language'] ?? '';
        _aiPersonality = response['aiPersonality'] ?? '';
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _editing = true);
    try {
      final url = Uri.parse('${ApiService.baseUrl}/Profile/update');
      await ApiService.post(
        url,
        body: {
          'userId': _profile?['userId'] ?? '',
          'userName': _username,
          'language': _language,
          'aiPersonality': _aiPersonality,
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      _fetchProfile();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: _loading
          ? Center(child: CircularProgressIndicator())
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
                    onPressed: _fetchProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _profile == null
          ? Center(
              child: Text('No profile data.', style: theme.textTheme.bodyLarge),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 16,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: isWide ? 48 : 36,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        size: isWide ? 54 : 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      initialValue: _username,
                      decoration: const InputDecoration(labelText: 'Username'),
                      onChanged: (v) => _username = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _language,
                      items: ['eng', 'ind', 'jpn', 'chi_sim', 'chi_tra']
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                      onChanged: (v) => _language = v,
                      decoration: const InputDecoration(labelText: 'Language'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _aiPersonality,
                      items: ['friendly', 'serious', 'funny', 'motivational']
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => _aiPersonality = v,
                      decoration: const InputDecoration(
                        labelText: 'AI Personality',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'XP: ${_profile?['xp'] ?? '-'}',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(width: 18),
                        Icon(
                          Icons.military_tech,
                          color: Colors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lvl ${_profile?['level'] ?? '-'}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(_editing ? 'Saving...' : 'Save'),
                      onPressed: _editing ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 40 : 32,
                          vertical: isWide ? 20 : 16,
                        ),
                        textStyle: theme.textTheme.titleMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
