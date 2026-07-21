import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_models.dart';
import 'theme.dart';

class HistoryDrawerModal extends StatelessWidget {
  final List<ChatThread> threads;
  final String? activeThreadId;
  final AppThemeMode themeMode;
  final Function(String) onSelectThread;
  final Function(String) onDeleteThread;
  final VoidCallback onCreateNewThread;

  const HistoryDrawerModal({
    super.key,
    required this.threads,
    required this.activeThreadId,
    required this.themeMode,
    required this.onSelectThread,
    required this.onDeleteThread,
    required this.onCreateNewThread,
  });

  static void show({
    required BuildContext context,
    required List<ChatThread> threads,
    required String? activeThreadId,
    required AppThemeMode themeMode,
    required Function(String) onSelectThread,
    required Function(String) onDeleteThread,
    required VoidCallback onCreateNewThread,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => HistoryDrawerModal(
        threads: threads,
        activeThreadId: activeThreadId,
        themeMode: themeMode,
        onSelectThread: onSelectThread,
        onDeleteThread: onDeleteThread,
        onCreateNewThread: onCreateNewThread,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = LibreAITheme.getColors(context, themeMode);
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (threads.length * 54.0 + 110.0).clamp(220.0, screenHeight * 0.65);

    return Container(
      height: targetHeight,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.monoBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.monoSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Chat History',
                      style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: colors.monoWhite)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      onCreateNewThread();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.accentClay,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(CupertinoIcons.add, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('New Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 0.5, color: colors.monoBorder),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: threads.length,
                itemBuilder: (context, index) {
                  final thread = threads[index];
                  final isSelected = thread.id == activeThreadId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.bgCardHover : colors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? colors.accentClay : colors.monoBorder, width: isSelected ? 1.5 : 0.5),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      onPressed: () {
                        onSelectThread(thread.id);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble_2,
                            size: 16,
                            color: isSelected ? colors.accentClay : colors.monoSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              thread.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? colors.monoWhite : colors.monoLightGray,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.all(4),
                            minimumSize: const Size(24, 24),
                            onPressed: () {
                              onDeleteThread(thread.id);
                              Navigator.pop(context);
                            },
                            child: Icon(CupertinoIcons.trash, size: 14, color: colors.monoSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
