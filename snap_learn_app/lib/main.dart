import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var androidInfo = await DeviceInfoPlugin().androidInfo;
  var release = androidInfo.version.release;

  if (release.contains("15")) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SnapLearnApp());
}

class SnapLearnApp extends StatelessWidget {
  const SnapLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // Vibrant blue
          brightness: Brightness.light,
          surfaceTint: const Color(0xFF1976D2),
        ).copyWith(
          primary: const Color(0xFF1976D2), // Main brand blue
          secondary: const Color(0xFF00BFAE), // Accent: teal
          tertiary: const Color(0xFFFFB300), // Soft blue-tinted background
          surface: Colors.white,
          error: const Color(0xFFD32F2F),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.black,
          onSurface: const Color(0xFF1A237E),
          onError: Colors.white,
        );
    return MaterialApp(
      title: 'Snap2Learn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surface.withOpacity(0.97),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          labelStyle: TextStyle(color: colorScheme.primary),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFF1976D2), width: 3),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: colorScheme.secondary,
          contentTextStyle: TextStyle(color: colorScheme.onSecondary),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {'/home': (_) => const HomeScreen()},
    );
  }
}
