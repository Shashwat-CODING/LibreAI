import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { auto, light, dark }

class LibreAIColors {
  final Color bgDark;
  final Color bgSurface;
  final Color bgCard;
  final Color bgCardHover;
  final Color monoWhite;
  final Color monoLightGray;
  final Color monoSecondary;
  final Color monoBorder;
  final Color accentClay;
  final Color userBubble;
  final Color aiBubble;

  const LibreAIColors({
    required this.bgDark,
    required this.bgSurface,
    required this.bgCard,
    required this.bgCardHover,
    required this.monoWhite,
    required this.monoLightGray,
    required this.monoSecondary,
    required this.monoBorder,
    required this.accentClay,
    required this.userBubble,
    required this.aiBubble,
  });

  // Light Palette (Anthropic Warm Cream)
  static const light = LibreAIColors(
    bgDark: Color(0xFFFBF9F5),
    bgSurface: Color(0xFFF4F0E8),
    bgCard: Color(0xFFFFFFFF),
    bgCardHover: Color(0xFFF0EBE1),
    monoWhite: Color(0xFF1F1E1B),
    monoLightGray: Color(0xFF4A4843),
    monoSecondary: Color(0xFF78756E),
    monoBorder: Color(0xFFE3DEC3),
    accentClay: Color(0xFFD97757),
    userBubble: Color(0xFFEFEBE1),
    aiBubble: Color(0xFFFBF9F5),
  );

  // Dark Palette (Anthropic Dark Obsidian)
  static const dark = LibreAIColors(
    bgDark: Color(0xFF141311),
    bgSurface: Color(0xFF1E1C18),
    bgCard: Color(0xFF262420),
    bgCardHover: Color(0xFF302D28),
    monoWhite: Color(0xFFFAF8F5),
    monoLightGray: Color(0xFFD9D4CC),
    monoSecondary: Color(0xFF999388),
    monoBorder: Color(0xFF3D3A34),
    accentClay: Color(0xFFD97757),
    userBubble: Color(0xFF2B2823),
    aiBubble: Color(0xFF1E1C18),
  );
}

class LibreAITheme {
  static LibreAIColors getColors(BuildContext context, AppThemeMode mode) {
    if (mode == AppThemeMode.light) return LibreAIColors.light;
    if (mode == AppThemeMode.dark) return LibreAIColors.dark;
    
    // Auto mode: check system brightness
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? LibreAIColors.dark : LibreAIColors.light;
  }

  static CupertinoThemeData getCupertinoTheme(BuildContext context, AppThemeMode mode) {
    final colors = getColors(context, mode);
    final isDark = (mode == AppThemeMode.dark) ||
        (mode == AppThemeMode.auto && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: colors.accentClay,
      scaffoldBackgroundColor: colors.bgDark,
      barBackgroundColor: colors.bgSurface,
      textTheme: CupertinoTextThemeData(
        primaryColor: colors.monoWhite,
        textStyle: GoogleFonts.outfit(
          color: colors.monoWhite,
          fontSize: 14,
        ),
      ),
    );
  }
}
