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
      );
      final storage = const FlutterSecureStorage();
      await storage.write(key: 'token', value: result['token']);
      await storage.write(key: 'refreshToken', value: result['refreshToken']);
      await storage.write(key: 'deviceId', value: result['deviceId']);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
      _AuthScreenState.setHasLoggedIn();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _showError = true;
      });
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showError = false);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
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
                content: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
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
                  vertical: 4,
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
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
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
      );
      final storage = const FlutterSecureStorage();
      // Registration returns only username, so prompt user to login
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      DefaultTabController.of(context).animateTo(0);
      _AuthScreenState.setHasLoggedIn();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _showError = true;
      });
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showError = false);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
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
                content: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
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
                  vertical: 4,
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
              DropdownMenuItem(value: 'chi_sim', child: Text('CN Simpfied')),
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
