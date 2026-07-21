import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'onboarding_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    setState(() {
      _showOnboarding = !completed;
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
      home: _showOnboarding
          ? OnboardingScreen(onOnboardingComplete: _completeOnboarding)
          : const ChatScreen(),
    );
  }
}
