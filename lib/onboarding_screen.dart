import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onOnboardingComplete;

  const OnboardingScreen({super.key, required this.onOnboardingComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  int _currentPage = 0;
  bool _obscureToken = true;

  @override
  void dispose() {
    _pageController.dispose();
    _userNameController.dispose();
    _accountController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _userNameController.text.trim();
    final accountId = _accountController.text.trim();
    final token = _tokenController.text.trim();

    if (name.isNotEmpty) {
      await prefs.setString('user_display_name', name);
    }
    if (accountId.isNotEmpty) {
      await prefs.setString('cf_account_id', accountId);
    }
    if (token.isNotEmpty) {
      await prefs.setString('cf_api_token', token);
    }

    await prefs.setBool('onboarding_completed', true);
    widget.onOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = LibreAITheme.getColors(context, AppThemeMode.auto);

    return CupertinoPageScaffold(
      backgroundColor: colors.bgDark,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header Branding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.accentClay.withValues(alpha: 0.4)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset('logo.png', width: 36, height: 36, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LibreAI',
                            style: GoogleFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: colors.monoWhite,
                            ),
                          ),
                          Text(
                            'Developed by CodErbauer',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: colors.accentClay,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_currentPage < 2)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _finishOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(fontSize: 14, color: colors.monoSecondary),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? colors.accentClay : colors.monoBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildIntroSlide(colors),
                      _buildPrivacySlide(colors),
                      _buildSetupCredentialsSlide(colors),
                    ],
                  ),
                ),

                // Navigation Button Row
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: colors.accentClay,
                      borderRadius: BorderRadius.circular(20),
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage == 2 ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Slide 1: Welcome & Overview
  Widget _buildIntroSlide(LibreAIColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.monoBorder),
            ),
            child: Icon(CupertinoIcons.gear_alt_fill, size: 54, color: colors.accentClay),
          ),
          const SizedBox(height: 28),
          Text(
            'Welcome to LibreAI',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: colors.monoWhite,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unrestricted access to Cloudflare Workers AI. Run DeepSeek, Kimi k2.7, Llama 3.3, and Flux 2 Klein image generation seamlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, color: colors.monoSecondary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse('https://www.youtube.com/watch?v=k1oGhb50qA4');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.accentClay.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.accentClay.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.play_circle_fill, size: 18, color: colors.accentClay),
                  const SizedBox(width: 8),
                  Text(
                    'Watch Video Setup Guide',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.accentClay,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.monoBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.checkmark_seal_fill, size: 18, color: colors.accentClay),
                const SizedBox(width: 8),
                Text(
                  'Created by CodErbauer',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.monoWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Privacy Guarantee & Zero Telemetry
  Widget _buildPrivacySlide(LibreAIColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.monoBorder),
            ),
            child: Icon(CupertinoIcons.lock_shield_fill, size: 54, color: colors.accentClay),
          ),
          const SizedBox(height: 28),
          Text(
            'Your Data Never Leaves\nYour Device',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: colors.monoWhite,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(
            icon: CupertinoIcons.device_laptop,
            title: '100% Local Storage',
            subtitle: 'Chat threads, API keys, and credentials are strictly saved on your local storage.',
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(
            icon: CupertinoIcons.eye_slash_fill,
            title: 'Zero Tracking or Telemetry',
            subtitle: 'No middleman servers, no user analytics, and no third-party data tracking.',
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(
            icon: CupertinoIcons.bolt_horizontal_fill,
            title: 'Direct API Connections',
            subtitle: 'LibreAI communicates directly with Cloudflare Workers AI using your own keys.',
            colors: colors,
          ),
        ],
      ),
    );
  }

  // Slide 3: Personal Setup (Name & Cloudflare Keys)
  Widget _buildSetupCredentialsSlide(LibreAIColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Personal Setup',
              style: GoogleFonts.newsreader(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: colors.monoWhite,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Configure your profile & optional Cloudflare keys',
              style: TextStyle(fontSize: 13, color: colors.monoSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // User Display Name
          Text(
            'YOUR NAME',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite),
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: _userNameController,
            placeholder: 'e.g. Shashwat',
            style: TextStyle(fontSize: 14, color: colors.monoWhite),
            placeholderStyle: TextStyle(color: colors.monoSecondary, fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.monoBorder),
            ),
          ),

          const SizedBox(height: 18),

          // Cloudflare Account ID
          Text(
            'CLOUDFLARE ACCOUNT ID (OPTIONAL)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite),
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: _accountController,
            placeholder: 'Paste your Account ID here',
            style: TextStyle(fontSize: 14, color: colors.monoWhite),
            placeholderStyle: TextStyle(color: colors.monoSecondary, fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.monoBorder),
            ),
          ),

          const SizedBox(height: 18),

          // Cloudflare API Token
          Text(
            'CLOUDFLARE API TOKEN (OPTIONAL)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite),
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: _tokenController,
            placeholder: 'Paste your API Token here',
            obscureText: _obscureToken,
            style: TextStyle(fontSize: 14, color: colors.monoWhite),
            placeholderStyle: TextStyle(color: colors.monoSecondary, fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.monoBorder),
            ),
            suffix: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => setState(() => _obscureToken = !_obscureToken),
              child: Icon(
                _obscureToken ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                size: 18,
                color: colors.monoSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            '*(You can also set or change your keys anytime in Settings).*',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: colors.monoSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required LibreAIColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.monoBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.accentClay.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colors.accentClay),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.monoWhite),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, height: 1.4, color: colors.monoSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
