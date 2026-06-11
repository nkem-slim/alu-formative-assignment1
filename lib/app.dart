import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'main_shell.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_rebuild);
    _init();
  }

  Future<void> _init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env missing — AuthService falls back to hardcoded defaults
    }
    _authService.init();
  }

  @override
  void dispose() {
    _authService.removeListener(_rebuild);
    _authService.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: _home(),
    );
  }

  Widget _home() {
    if (!_authService.initialized) return _SplashScreen();
    if (!_authService.onboardingSeen) {
      return OnboardingScreen(authService: _authService);
    }
    if (!_authService.isLoggedIn) {
      return LoginScreen(authService: _authService);
    }
    return MainShell(authService: _authService);
  }
}

class _SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF071D3A),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFFDB515)),
      ),
    );
  }
}
