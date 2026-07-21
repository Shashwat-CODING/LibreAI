import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'onboarding_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LibreAIApp());
}

class LibreAIApp extends StatefulWidget {
  const LibreAIApp({super.key});

  @override
  State<LibreAIApp> createState() => _LibreAIAppState();
}

class _LibreAIAppState extends State<LibreAIApp> {
  bool _isLoading = true;
  bool _showOnboarding = true;
  AppThemeMode _appThemeMode = AppThemeMode.auto;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndTheme();
  }

  Future<void> _checkOnboardingAndTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    final themeStr = prefs.getString('app_theme_mode') ?? 'auto';

    AppThemeMode loadedMode = AppThemeMode.auto;
    if (themeStr == 'light' || themeStr == 'AppThemeMode.light') {
      loadedMode = AppThemeMode.light;
    } else if (themeStr == 'dark' || themeStr == 'AppThemeMode.dark') {
      loadedMode = AppThemeMode.dark;
    }

    setState(() {
      _showOnboarding = !completed;
      _appThemeMode = loadedMode;
      _isLoading = false;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: CupertinoPageScaffold(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }

    return CupertinoApp(
      title: 'LibreAI',
      debugShowCheckedModeBanner: false,
      theme: LibreAITheme.getCupertinoTheme(context, _appThemeMode),
      home: _showOnboarding
          ? OnboardingScreen(onOnboardingComplete: _completeOnboarding)
          : const ChatScreen(),
    );
  }
}
