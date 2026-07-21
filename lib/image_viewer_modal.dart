import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class ImageViewerModal extends StatelessWidget {
  final String rawInput;

  const ImageViewerModal({super.key, required this.rawInput});

  static void show(BuildContext context, String rawInput) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ImageViewerModal(rawInput: rawInput),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = LibreAITheme.getColors(context, AppThemeMode.auto);
    final cleanBase64 = rawInput.contains(',') ? rawInput.split(',').last.trim() : rawInput.trim();
    final bytes = base64Decode(cleanBase64);

    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: CupertinoButton(
                padding: const EdgeInsets.all(10),
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(20),
                onPressed: () => Navigator.pop(context),
                child: Icon(CupertinoIcons.xmark, color: colors.monoWhite, size: 18),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: colors.accentClay,
                borderRadius: BorderRadius.circular(20),
                onPressed: () async {
                  try {
                    final file = File('/Users/shashwat/Desktop/libreai_download_${DateTime.now().millisecondsSinceEpoch}.png');
                    await file.writeAsBytes(bytes);
                    if (context.mounted) {
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('Saved!'),
                          content: Text('Image saved to:\n${file.path}'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Download error: $e');
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.arrow_down_to_line, color: Colors.black, size: 16),
                    SizedBox(width: 6),
                    Text('Download', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
