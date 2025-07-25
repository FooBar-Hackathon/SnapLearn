import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  bool _showFirstTimeMessage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLoggedIn = prefs.getBool('hasLoggedIn') ?? false;
    if (!hasLoggedIn) {
      setState(() {
        _showFirstTimeMessage = true;
      });
    }
  }

  static Future<void> setHasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedIn', true);
  }

  static void hideFirstTimeMessage(BuildContext context) {
    final state = context.findAncestorStateOfType<_AuthScreenState>();
    state?._hideFirstTimeMessage();
  }

  void _hideFirstTimeMessage() {
    setState(() {
      _showFirstTimeMessage = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                if (_showFirstTimeMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: MaterialBanner(
                      backgroundColor: theme.colorScheme.secondary.withOpacity(
                        0.12,
                      ),
                      content: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'The days of rote learning are numbered. Snap2Learn provides an AI-powered alternative to everyone, everywhere.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: theme.colorScheme.primary,
                          onPressed: _hideFirstTimeMessage,
                          tooltip: 'Dismiss',
                        ),
                      ],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  ),
                Image.asset(
                  'assets/logo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  'Snap2Learn',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: 370,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: theme.hintColor,
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                              insets: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                            ),
                            labelStyle: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: const [
                              Tab(text: 'Login'),
                              Tab(text: 'Register'),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            final offset = _currentTab == 0
                                ? const Offset(-0.1, 0)
                                : const Offset(0.1, 0);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: offset,
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _currentTab == 0
                              ? const Padding(
                                  key: ValueKey('login'),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: LoginForm(),
                                )
                              : const Padding(
                                  key: ValueKey('register'),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: RegisterForm(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Learn by snapping. Compete. Have fun.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showError = false;
  Timer? _errorTimer;

  Future<void> _login() async {
    // Validate inputs first
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields';
        _showError = true;
      });
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showError = false);
      });
      return;
    }

    // Check network connection

    setState(() {
      _loading = true;
      _error = null;
      _showError = false;
      _errorTimer?.cancel();
    });

    try {
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      ).timeout(const Duration(seconds: 30));

      if (result['token'] == null) {
        throw Exception('Invalid server response - missing token');
      }

      final storage = const FlutterSecureStorage();
      await Future.wait([
        storage.write(key: 'token', value: result['token']),
        storage.write(key: 'refreshToken', value: result['refreshToken']),
        if (result['deviceId'] != null)
          storage.write(key: 'deviceId', value: result['deviceId']),
      ]);

      // Fetch user data
      try {
        final profile = await ApiService.getProfile();
        if (profile == null) {
          throw Exception('Failed to fetch user profile');
        }
      } catch (e) {
        debugPrint('Profile fetch error: $e');
        // Continue even if profile fetch fails - we can retry later
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
      await _AuthScreenState.setHasLoggedIn();
    } on TimeoutException {
      setState(() {
        _error = 'Connection timeout. Please try again.';
        _showError = true;
      });
    } on FormatException {
      setState(() {
        _error = 'Invalid server response format';
        _showError = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        if (_error!.contains('SocketException') ||
            _error!.contains('Network is unreachable')) {
          _error = 'Network error. Please check your connection.';
        }
        _showError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      _errorTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showError && _error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MaterialBanner(
                backgroundColor: theme.colorScheme.errorContainer,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Failed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: theme.colorScheme.onErrorContainer,
                    onPressed: () => setState(() => _showError = false),
                    tooltip: 'Dismiss',
                  ),
                ],
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
            ),
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loading
                ? null
                : () {
                    // Add forgot password functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset functionality coming soon!',
                        ),
                      ),
                    );
                  },
            child: Text(
              'Forgot password?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedLanguage = 'eng';
  bool _loading = false;
  String? _error;
  bool _showError = false;
  Timer? _errorTimer;

  Future<void> _register() async {
    // Validate inputs first
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields';
        _showError = true;
      });
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showError = false);
      });
      return;
    }

    // Check network connection

    setState(() {
      _loading = true;
      _error = null;
      _showError = false;
      _errorTimer?.cancel();
    });

    try {
      final result = await ApiService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedLanguage,
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          duration: Duration(seconds: 3),
        ),
      );
      DefaultTabController.of(context).animateTo(0);
      await _AuthScreenState.setHasLoggedIn();
    } on TimeoutException {
      setState(() {
        _error = 'Connection timeout. Please try again.';
        _showError = true;
      });
    } on FormatException {
      setState(() {
        _error = 'Invalid server response format';
        _showError = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        if (_error!.contains('SocketException') ||
            _error!.contains('Network is unreachable')) {
          _error = 'Network error. Please check your connection.';
        }
        _showError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      _errorTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AutofillGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showError && _error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MaterialBanner(
                backgroundColor: theme.colorScheme.errorContainer,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Failed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: theme.colorScheme.onErrorContainer,
                    onPressed: () => setState(() => _showError = false),
                    tooltip: 'Dismiss',
                  ),
                ],
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
            ),
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
            ),
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: InputDecoration(
              labelText: 'System Language',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'eng', child: Text('EN')),
              DropdownMenuItem(value: 'ind', child: Text('ID')),
              DropdownMenuItem(value: 'chi_sim', child: Text('CN Simplified')),
              DropdownMenuItem(value: 'chi_tra', child: Text('CN Traditional')),
              DropdownMenuItem(value: 'jpn', child: Text('JP')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedLanguage = val);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }
}
