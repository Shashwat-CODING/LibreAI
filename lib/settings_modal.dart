import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_models.dart';
import 'models.dart';
import 'theme.dart';

class SettingsModal extends StatefulWidget {
  final String cfAccountId;
  final String cfApiToken;
  final String selectedTextModelId;
  final String selectedImageModelId;
  final String systemPrompt;
  final AppThemeMode themeMode;
  final Function({
    required String accountId,
    required String apiToken,
    required String textModelId,
    required String imageModelId,
    required String systemPrompt,
    required AppThemeMode themeMode,
  }) onSave;
  final VoidCallback onRestoreDefaults;
  final VoidCallback onResetAllDataAndOnboard;

  const SettingsModal({
    super.key,
    required this.cfAccountId,
    required this.cfApiToken,
    required this.selectedTextModelId,
    required this.selectedImageModelId,
    required this.systemPrompt,
    required this.themeMode,
    required this.onSave,
    required this.onRestoreDefaults,
    required this.onResetAllDataAndOnboard,
  });

  static void show({
    required BuildContext context,
    required String cfAccountId,
    required String cfApiToken,
    required String selectedTextModelId,
    required String selectedImageModelId,
    required String systemPrompt,
    required AppThemeMode themeMode,
    required Function({
      required String accountId,
      required String apiToken,
      required String textModelId,
      required String imageModelId,
      required String systemPrompt,
      required AppThemeMode themeMode,
    }) onSave,
    required VoidCallback onRestoreDefaults,
    required VoidCallback onResetAllDataAndOnboard,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => SettingsModal(
        cfAccountId: cfAccountId,
        cfApiToken: cfApiToken,
        selectedTextModelId: selectedTextModelId,
        selectedImageModelId: selectedImageModelId,
        systemPrompt: systemPrompt,
        themeMode: themeMode,
        onSave: onSave,
        onRestoreDefaults: onRestoreDefaults,
        onResetAllDataAndOnboard: onResetAllDataAndOnboard,
      ),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late TextEditingController _accountController;
  late TextEditingController _tokenController;
  late TextEditingController _systemPromptController;

  late String _textModel;
  late String _imageModel;
  late AppThemeMode _currentThemeMode;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(text: widget.cfAccountId);
    _tokenController = TextEditingController(text: widget.cfApiToken);
    _systemPromptController = TextEditingController(text: widget.systemPrompt);

    _textModel = widget.selectedTextModelId;
    _imageModel = widget.selectedImageModelId;
    _currentThemeMode = widget.themeMode;
  }

  @override
  void dispose() {
    _accountController.dispose();
    _tokenController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = LibreAITheme.getColors(context, _currentThemeMode);
        final visionModels = availableModels.where((m) => m.category == ModelCategory.vision).toList();
        final textModels = availableModels.where((m) => m.category == ModelCategory.text).toList();
        final imageGenModels = availableModels.where((m) => m.category == ModelCategory.imageGen).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: colors.monoBorder, width: 0.5),
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
                      Text('Settings & AI Model Selection',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: colors.monoWhite)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          widget.onSave(
                            accountId: _accountController.text.trim(),
                            apiToken: _tokenController.text.trim(),
                            textModelId: _textModel,
                            imageModelId: _imageModel,
                            systemPrompt: _systemPromptController.text,
                            themeMode: _currentThemeMode,
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.accentClay,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 0.5, color: colors.monoBorder),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Theme Mode Picker (Auto / Light / Dark)
                        Text('1. APP THEME MODE',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite)),
                        const SizedBox(height: 4),
                        Text('Choose Light, Dark, or System Auto Default theme.',
                            style: TextStyle(fontSize: 10, color: colors.monoSecondary)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<AppThemeMode>(
                            groupValue: _currentThemeMode,
                            children: const {
                              AppThemeMode.auto: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text('Auto System', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              AppThemeMode.light: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text('Light', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              AppThemeMode.dark: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text('Dark', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            },
                            onValueChanged: (val) {
                              if (val != null) {
                                setState(() => _currentThemeMode = val);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        // LLM Text & Vision Models Selection (1 Text Model)
                        Text('2. SELECT CHAT & REASONING MODEL (LLM)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite)),
                        const SizedBox(height: 4),
                        Text('Pick 1 primary LLM model to handle all conversation & reasoning.',
                            style: TextStyle(fontSize: 10, color: colors.monoSecondary)),
                        const SizedBox(height: 8),

                        Text('Multimodal Vision Models',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.monoSecondary)),
                        const SizedBox(height: 4),
                        _buildPickerGroup(visionModels, _textModel, (val) => setState(() => _textModel = val), colors),

                        const SizedBox(height: 10),
                        Text('Text & Code Reasoning Models',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.monoSecondary)),
                        const SizedBox(height: 4),
                        _buildPickerGroup(textModels, _textModel, (val) => setState(() => _textModel = val), colors),

                        const SizedBox(height: 20),
                        // Image Generation Model Selection (1 Image Model)
                        Text('2. SELECT IMAGE GENERATION MODEL',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite)),
                        const SizedBox(height: 4),
                        Text('Pick 1 dedicated image model used whenever drawing or generating art.',
                            style: TextStyle(fontSize: 10, color: colors.monoSecondary)),
                        const SizedBox(height: 8),
                        _buildPickerGroup(imageGenModels, _imageModel, (val) => setState(() => _imageModel = val), colors),

                        const SizedBox(height: 20),
                        // Cloudflare Credentials
                        Row(
                          children: [
                            Text('3. CLOUDFLARE CREDENTIALS (OPTIONAL)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                final url = Uri.parse('https://www.youtube.com/watch?v=k1oGhb50qA4');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.accentClay.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.accentClay.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.play_circle_fill, size: 12, color: colors.accentClay),
                                    const SizedBox(width: 4),
                                    Text('Video Guide', style: TextStyle(fontSize: 10, color: colors.accentClay, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _accountController,
                          placeholder: 'Cloudflare Account ID',
                          style: TextStyle(fontSize: 13, color: colors.monoWhite),
                          placeholderStyle: TextStyle(color: colors.monoSecondary, fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.monoBorder),
                          ),
                          suffix: CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            onPressed: () {
                              final text = _accountController.text.trim();
                              if (text.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: text));
                              }
                            },
                            child: Icon(CupertinoIcons.doc_on_doc, size: 16, color: colors.monoSecondary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _tokenController,
                          placeholder: 'Cloudflare API Token',
                          obscureText: _obscureToken,
                          style: TextStyle(fontSize: 13, color: colors.monoWhite),
                          placeholderStyle: TextStyle(color: colors.monoSecondary, fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.monoBorder),
                          ),
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                onPressed: () {
                                  setState(() => _obscureToken = !_obscureToken);
                                },
                                child: Icon(
                                  _obscureToken ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                  size: 16,
                                  color: colors.monoSecondary,
                                ),
                              ),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                onPressed: () {
                                  final text = _tokenController.text.trim();
                                  if (text.isNotEmpty) {
                                    Clipboard.setData(ClipboardData(text: text));
                                  }
                                },
                                child: Icon(CupertinoIcons.doc_on_doc, size: 16, color: colors.monoSecondary),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Custom System Prompt
                        Row(
                          children: [
                            Text('4. CUSTOM SYSTEM PROMPT PERSONA',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.monoWhite)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _systemPromptController.text = kDefaultUserSystemPrompt,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.monoBorder),
                                ),
                                child: Text('Reset Prompt', style: TextStyle(fontSize: 10, color: colors.monoWhite, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Tool execution protocols (Image Gen & Code) are protected automatically.',
                            style: TextStyle(fontSize: 10, color: colors.monoSecondary)),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _systemPromptController,
                          maxLines: 4,
                          style: TextStyle(fontSize: 12, color: colors.monoWhite),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.monoBorder),
                          ),
                        ),

                        const SizedBox(height: 24),
                        // Restore Defaults iOS Pill Button
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              widget.onRestoreDefaults();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: colors.bgCardHover,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: colors.monoBorder),
                              ),
                              child: const Center(
                                child: Text(
                                  'Restore All Factory Defaults',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Clear Cache & Reset All Data Button
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (dialogContext) => CupertinoAlertDialog(
                                  title: const Text('Clear Cache & Reset App Data?'),
                                  content: const Text(
                                    'This will delete all saved API keys, chat history threads, system prompts, and custom settings. You will be taken back to the Onboarding Screen.',
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.pop(dialogContext),
                                    ),
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      child: const Text('Clear Everything'),
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        Navigator.pop(context);
                                        widget.onResetAllDataAndOnboard();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: CupertinoColors.systemRed.withValues(alpha: 0.5)),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(CupertinoIcons.trash_fill, size: 16, color: CupertinoColors.systemRed),
                                    SizedBox(width: 6),
                                    Text(
                                      'Clear Cache & Reset All App Data',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildPickerGroup(List<AIModel> models, String selectedId, Function(String) onSelect, LibreAIColors colors) {
    return Column(
      children: models.map((m) {
        final isSelected = m.id == selectedId;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: isSelected ? colors.bgCardHover : colors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? colors.accentClay : colors.monoBorder, width: isSelected ? 1.5 : 0.5),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            onPressed: () => onSelect(m.id),
            child: Row(
              children: [
                Icon(
                  isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                  size: 18,
                  color: isSelected ? colors.accentClay : colors.monoSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? colors.monoWhite : colors.monoLightGray)),
                      Text(m.description, style: TextStyle(fontSize: 10, color: colors.monoSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
