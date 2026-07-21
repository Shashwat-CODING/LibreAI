import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';
import 'theme.dart';

class TypewriterModelTitle extends StatefulWidget {
  final String textModelId;
  final String imageModelId;
  final AppThemeMode themeMode;

  const TypewriterModelTitle({
    super.key,
    required this.textModelId,
    required this.imageModelId,
    required this.themeMode,
  });

  @override
  State<TypewriterModelTitle> createState() => _TypewriterModelTitleState();
}

class _TypewriterModelTitleState extends State<TypewriterModelTitle> {
  String _displayedText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void didUpdateWidget(TypewriterModelTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textModelId != widget.textModelId || oldWidget.imageModelId != widget.imageModelId) {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer?.cancel();

    int mode = 0; // 0: LLM, 1: IMG
    int charIndex = 0;
    bool isDeleting = false;
    int pauseCounter = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;

      final activeTextModel = availableModels.firstWhere(
        (m) => m.id == widget.textModelId,
        orElse: () => availableModels.first,
      );
      final activeImageModel = availableModels.firstWhere(
        (m) => m.id == widget.imageModelId,
        orElse: () => availableModels.firstWhere((m) => m.category == ModelCategory.imageGen),
      );

      final targetString = mode == 0
          ? 'LLM: ${activeTextModel.name}'
          : 'IMG: ${activeImageModel.name}';

      if (pauseCounter > 0) {
        pauseCounter--;
        return;
      }

      if (!isDeleting) {
        if (charIndex < targetString.length) {
          charIndex++;
          setState(() => _displayedText = targetString.substring(0, charIndex));
        } else {
          pauseCounter = 33;
          isDeleting = true;
        }
      } else {
        if (charIndex > 0) {
          charIndex--;
          final currentSub = targetString.length >= charIndex ? targetString.substring(0, charIndex) : '';
          setState(() => _displayedText = currentSub);
        } else {
          isDeleting = false;
          mode = mode == 0 ? 1 : 0;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = LibreAITheme.getColors(context, widget.themeMode);
    return Text(
      _displayedText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: colors.monoSecondary, fontWeight: FontWeight.w500),
    );
  }
}
