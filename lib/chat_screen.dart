import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'api_service.dart';
import 'chat_models.dart';
import 'history_drawer_modal.dart';
import 'image_viewer_modal.dart';
import 'models.dart';
import 'onboarding_screen.dart';
import 'settings_modal.dart';
import 'theme.dart';
import 'typewriter_model_title.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatThread> _threads = [];
  String? _activeThreadId;
  bool _isLoading = false;
  String? _selectedImageBase64;

  // Settings
  String _cfAccountId = '';
  String _cfApiToken = '';
  String _selectedTextModelId = '@cf/moonshotai/kimi-k2.7-code';
  String _selectedImageModelId = '@cf/black-forest-labs/flux-2-klein-4b';
  String _systemPrompt = kDefaultUserSystemPrompt;
  AppThemeMode _themeMode = AppThemeMode.auto;
  bool _isSidebarOpen = true;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndThreads();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSettingsAndThreads() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cfAccountId = prefs.getString('cf_account_id') ?? '';
      _cfApiToken = prefs.getString('cf_api_token') ?? '';
      _selectedTextModelId = prefs.getString('selected_text_model') ??
          '@cf/moonshotai/kimi-k2.7-code';
      _selectedImageModelId = prefs.getString('selected_image_model') ??
          '@cf/black-forest-labs/flux-2-klein-4b';
      _systemPrompt =
          prefs.getString('system_prompt') ?? kDefaultUserSystemPrompt;
      if (_systemPrompt.contains('[GENERATE_IMAGE:')) {
        _systemPrompt = kDefaultUserSystemPrompt;
        prefs.setString('system_prompt', kDefaultUserSystemPrompt);
      }

      final themeModeStr = prefs.getString('app_theme_mode') ?? 'auto';
      if (themeModeStr == 'light' || themeModeStr == 'AppThemeMode.light') {
        _themeMode = AppThemeMode.light;
      } else if (themeModeStr == 'dark' || themeModeStr == 'AppThemeMode.dark') {
        _themeMode = AppThemeMode.dark;
      } else {
        _themeMode = AppThemeMode.auto;
      }

      final threadsJson = prefs.getString('chat_threads');
      if (threadsJson != null) {
        try {
          final List<dynamic> decoded = jsonDecode(threadsJson);
          _threads = decoded
              .map((item) => ChatThread.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (_) {
          _threads = [];
        }
      }

      if (_threads.isEmpty) {
        _createNewThread();
      } else {
        _activeThreadId = _threads.first.id;
      }
    });
  }

  Future<void> _saveThreads() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_threads.map((t) => t.toJson()).toList());
    await prefs.setString('chat_threads', jsonStr);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cf_account_id', _cfAccountId);
    await prefs.setString('cf_api_token', _cfApiToken);
    await prefs.setString('selected_text_model', _selectedTextModelId);
    await prefs.setString('selected_image_model', _selectedImageModelId);
    await prefs.setString('system_prompt', _systemPrompt);
    await prefs.setString('app_theme_mode', _themeMode.name);
  }

  ChatThread? get _activeThread {
    if (_activeThreadId == null) return null;
    try {
      return _threads.firstWhere((t) => t.id == _activeThreadId);
    } catch (_) {
      return null;
    }
  }

  void _createNewThread() {
    final newThread = ChatThread(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
    setState(() {
      _threads.insert(0, newThread);
      _activeThreadId = newThread.id;
      _selectedImageBase64 = null;
    });
    _saveThreads();
  }

  void _deleteThread(String threadId) {
    _threads.removeWhere((t) => t.id == threadId);
    if (_activeThreadId == threadId) {
      _activeThreadId = _threads.isNotEmpty ? _threads.first.id : null;
    }
    if (_threads.isEmpty) {
      final newThread = ChatThread(
        id: const Uuid().v4(),
        title: 'New Chat',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );
      _threads.add(newThread);
      _activeThreadId = newThread.id;
    }
    setState(() {});
    _saveThreads();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _selectedImageBase64 = base64Encode(bytes));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = (customText ?? _promptController.text).trim();
    if ((text.isEmpty && _selectedImageBase64 == null) || _isLoading || _activeThread == null) return;

    if (customText == null) {
      _promptController.clear();
    }

    final activeTextModelObj = availableModels.firstWhere(
      (m) => m.id == _selectedTextModelId,
      orElse: () => availableModels.first,
    );

    final activeImageModelObj = availableModels.firstWhere(
      (m) => m.id == _selectedImageModelId,
      orElse: () => availableModels.firstWhere((m) => m.category == ModelCategory.imageGen),
    );

    final thread = _activeThread!;
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: text.isEmpty ? 'Analyze attached image' : text,
      imageBase64: _selectedImageBase64,
      timestamp: DateTime.now(),
    );

    setState(() {
      thread.messages.add(userMsg);
      thread.updatedAt = DateTime.now();
      if (thread.messages.length == 1) {
        thread.title = text.length > 25 ? '${text.substring(0, 25)}...' : (text.isEmpty ? 'Image Analysis' : text);
      }
      _isLoading = true;
      _selectedImageBase64 = null;
    });
    _saveThreads();
    _scrollToBottom();

    // Check if Cloudflare Credentials are entered
    if (_cfAccountId.isEmpty || _cfApiToken.isEmpty) {
      final credentialPromptMsg = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: 'Cloudflare credentials required.\n\n'
            'Please enter your **Cloudflare Account ID** and **Cloudflare API Token** in Settings to start chatting with models.',
        timestamp: DateTime.now(),
      );

      setState(() {
        thread.messages.add(credentialPromptMsg);
        _isLoading = false;
      });
      _saveThreads();
      _scrollToBottom();
      return;
    }

    // Process through selected LLM text model
    try {
      final responseContent = await ApiService.callCloudflareWorkersAI(
        history: thread.messages,
        model: activeTextModelObj,
        systemPrompt: _systemPrompt,
        cfAccountId: _cfAccountId,
        cfApiToken: _cfApiToken,
      );
      
      // Tool execution check: If LLM requested image generation
      final toolRegExp = RegExp(r'\[GENERATE_IMAGE:\s*(.*?)\]', caseSensitive: false, dotAll: true);
      final match = toolRegExp.firstMatch(responseContent);

      if (match != null) {
        final imagePrompt = match.group(1)!.trim();
        final cleanText = responseContent.replaceAll(toolRegExp, '').trim();

        final imageResult = await ApiService.callCloudflareImageGen(
          rawPrompt: imagePrompt,
          selectedImageModelId: _selectedImageModelId,
          cfAccountId: _cfAccountId,
          cfApiToken: _cfApiToken,
        );
        final aiMsg = ChatMessage(
          id: const Uuid().v4(),
          role: 'assistant',
          content: cleanText.isEmpty
              ? 'Generated image using **${activeImageModelObj.name}** for prompt: *"$imagePrompt"*'
              : cleanText,
          generatedImageUrl: imageResult,
          timestamp: DateTime.now(),
        );

        setState(() {
          thread.messages.add(aiMsg);
          thread.updatedAt = DateTime.now();
          _isLoading = false;
        });
      } else {
        final aiMsg = ChatMessage(
          id: const Uuid().v4(),
          role: 'assistant',
          content: responseContent,
          timestamp: DateTime.now(),
        );

        setState(() {
          thread.messages.add(aiMsg);
          thread.updatedAt = DateTime.now();
          _isLoading = false;
        });
      }
      _saveThreads();
      _scrollToBottom();
    } catch (e) {
      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: '⚠️ **Network / API Error**: $e\n\n'
            '*(You can configure your Cloudflare Account ID & API Key in Settings).*',
        timestamp: DateTime.now(),
      );
      setState(() {
        thread.messages.add(errorMsg);
        _isLoading = false;
      });
      _saveThreads();
      _scrollToBottom();
    }
  }

  void _openSettingsSheet() {
    SettingsModal.show(
      context: context,
      cfAccountId: _cfAccountId,
      cfApiToken: _cfApiToken,
      selectedTextModelId: _selectedTextModelId,
      selectedImageModelId: _selectedImageModelId,
      systemPrompt: _systemPrompt,
      themeMode: _themeMode,
      onSave: ({
        required accountId,
        required apiToken,
        required textModelId,
        required imageModelId,
        required systemPrompt,
        required themeMode,
      }) {
        setState(() {
          _cfAccountId = accountId;
          _cfApiToken = apiToken;
          _selectedTextModelId = textModelId;
          _selectedImageModelId = imageModelId;
          _systemPrompt = systemPrompt;
          _themeMode = themeMode;
        });
        _saveSettings();
      },
      onRestoreDefaults: () {
        setState(() {
          _cfAccountId = '';
          _cfApiToken = '';
          _selectedTextModelId = '@cf/moonshotai/kimi-k2.7-code';
          _selectedImageModelId = '@cf/black-forest-labs/flux-2-klein-4b';
          _systemPrompt = kDefaultUserSystemPrompt;
          _themeMode = AppThemeMode.auto;
        });
        _saveSettings();
      },
      onResetAllDataAndOnboard: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (context) => OnboardingScreen(
                onOnboardingComplete: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => const ChatScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
            (route) => false,
          );
        }
      },
    );
  }

  void _showHistorySheet() {
    HistoryDrawerModal.show(
      context: context,
      threads: _threads,
      activeThreadId: _activeThreadId,
      themeMode: _themeMode,
      onSelectThread: (id) => setState(() => _activeThreadId = id),
      onDeleteThread: _deleteThread,
      onCreateNewThread: _createNewThread,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = LibreAITheme.getColors(context, _themeMode);
    final themeData = LibreAITheme.getCupertinoTheme(context, _themeMode);
    final isWideScreen = MediaQuery.of(context).size.width >= 768;

    return CupertinoTheme(
      data: themeData,
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colors.bgDark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Floating Desktop Sidebar Card
                if (isWideScreen && _isSidebarOpen) ...[
                  Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: colors.bgSurface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.monoBorder.withValues(alpha: 0.6), width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildIosSidebar(colors),
                    ),
                  ),
                ],

                // Main Workspace
                Expanded(
                  child: Stack(
                    children: [
                      // Chat Messages List
                      Positioned.fill(
                        child: _activeThread == null || _activeThread!.messages.isEmpty
                            ? _buildMinimalEmptyState(colors)
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 72,
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 96,
                                ),
                                itemCount: _activeThread!.messages.length + (_isLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < _activeThread!.messages.length) {
                                    return _buildIosMessageBubble(_activeThread!.messages[index], colors);
                                  } else {
                                    return _buildIosLoadingBubble(colors);
                                  }
                                },
                              ),
                      ),

                      // Floating Glassmorphic Top Navigation Capsule
                      Positioned(
                        top: 4,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colors.bgSurface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: colors.monoBorder.withValues(alpha: 0.6), width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  if (isWideScreen) {
                                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                                  } else {
                                    _showHistorySheet();
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.sidebar_left,
                                  size: 20,
                                  color: colors.monoWhite,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LibreAI',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: colors.monoWhite),
                                    ),
                                    TypewriterModelTitle(
                                      textModelId: _selectedTextModelId,
                                      imageModelId: _selectedImageModelId,
                                      themeMode: _themeMode,
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _createNewThread,
                                child: Icon(CupertinoIcons.square_pencil, size: 20, color: colors.monoWhite),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _openSettingsSheet,
                                child: Icon(CupertinoIcons.gear_alt, size: 20, color: colors.monoWhite),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Glassmorphic Input Capsule Bar
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                        child: _buildIosFloatingInputBar(colors),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIosSidebar(LibreAIColors colors) {
    return Container(
      color: colors.bgSurface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('LibreAI',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colors.monoWhite)),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _createNewThread,
                child: Icon(CupertinoIcons.square_pencil, size: 18, color: colors.monoWhite),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: colors.monoBorder),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _threads.length,
              itemBuilder: (context, index) {
                final thread = _threads[index];
                final isSelected = thread.id == _activeThreadId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.bgCardHover : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    onPressed: () => setState(() => _activeThreadId = thread.id),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.chat_bubble,
                            size: 14, color: isSelected ? colors.monoWhite : colors.monoSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            thread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? colors.monoWhite : colors.monoSecondary,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(20, 20),
                          onPressed: () => _deleteThread(thread.id),
                          child: Icon(CupertinoIcons.trash, size: 12, color: colors.monoSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 0.5, color: colors.monoBorder),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8),
            onPressed: _openSettingsSheet,
            child: Row(
              children: [
                Icon(CupertinoIcons.gear_alt, size: 16, color: colors.monoSecondary),
                const SizedBox(width: 8),
                Text('Settings & Models', style: TextStyle(fontSize: 13, color: colors.monoSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalEmptyState(LibreAIColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: colors.monoBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('logo.png', width: 56, height: 56, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LibreAI',
            style: GoogleFonts.newsreader(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: colors.monoWhite,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vision, Multimodal LLMs & Dedicated Image Models',
            style: TextStyle(fontSize: 13, color: colors.monoSecondary),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildIosChip('Analyze Photo', colors),
              _buildIosChip('Generate Image: Cyberpunk City', colors),
              _buildIosChip('Write Flutter Code', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIosChip(String text, LibreAIColors colors) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (text.contains('Analyze Photo')) {
          _pickImage();
        } else if (text.contains('Generate Image')) {
          _sendMessage('Cyberpunk futuristic neon city at night');
        } else {
          _sendMessage(text);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.monoBorder, width: 0.5),
        ),
        child: Text(text, style: TextStyle(fontSize: 12, color: colors.monoLightGray)),
      ),
    );
  }

  Widget _buildSafeImageFromBase64(String input, {required double height, required LibreAIColors colors}) {
    final cardColor = colors.bgCard;
    final secondaryColor = colors.monoSecondary;
    try {
      final cleanBase64 = input.contains(',') ? input.split(',').last.trim() : input.trim();
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: cardColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.photo, color: secondaryColor, size: 28),
                  const SizedBox(height: 6),
                  Text('Image preview unavailable', style: TextStyle(fontSize: 11, color: secondaryColor)),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {
      return Container(
        height: height,
        color: cardColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.photo, color: secondaryColor, size: 28),
              const SizedBox(height: 6),
              Text('Invalid image data', style: TextStyle(fontSize: 11, color: secondaryColor)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildIosMessageBubble(ChatMessage msg, LibreAIColors colors) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: isUser
                ? Container(
                    constraints: const BoxConstraints(maxWidth: 580),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.userBubble,
                      borderRadius: BorderRadius.circular(18).copyWith(bottomRight: const Radius.circular(4)),
                      border: Border.all(color: colors.monoBorder, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.imageBase64 != null) ...[
                          GestureDetector(
                            onTap: () => ImageViewerModal.show(context, msg.imageBase64!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildSafeImageFromBase64(msg.imageBase64!, height: 220, colors: colors),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          msg.content,
                          style: TextStyle(fontSize: 14, color: colors.monoWhite, height: 1.4),
                        ),
                      ],
                    ),
                  )
                : Container(
                    constraints: const BoxConstraints(maxWidth: 680),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.generatedImageUrl != null) ...[
                          GestureDetector(
                            onTap: () => ImageViewerModal.show(context, msg.generatedImageUrl!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildSafeImageFromBase64(msg.generatedImageUrl!, height: 340, colors: colors),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        MarkdownBody(
                          data: msg.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 15, color: colors.monoWhite, height: 1.6),
                            code: GoogleFonts.firaCode(
                              backgroundColor: colors.bgSurface,
                              color: colors.monoWhite,
                              fontSize: 12.5,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: colors.bgSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.monoBorder, width: 0.5),
                            ),
                            h1: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: colors.monoWhite),
                            h2: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colors.monoWhite),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosLoadingBubble(LibreAIColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.aiBubble,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.monoBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(radius: 8, color: colors.monoWhite),
                const SizedBox(width: 8),
                Text('Processing AI request...', style: TextStyle(fontSize: 12, color: colors.monoSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosFloatingInputBar(LibreAIColors colors) {
    final activeTextModelObj = availableModels.firstWhere(
      (m) => m.id == _selectedTextModelId,
      orElse: () => availableModels.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bgSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.monoBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (activeTextModelObj.category == ModelCategory.vision) ...[
            CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: _pickImage,
              child: Icon(
                CupertinoIcons.photo_on_rectangle,
                size: 20,
                color: _selectedImageBase64 != null ? colors.accentClay : colors.monoSecondary,
              ),
            ),
            if (_selectedImageBase64 != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.monoBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.photo, size: 12, color: colors.accentClay),
                    const SizedBox(width: 4),
                    Text('Photo attached', style: TextStyle(fontSize: 10, color: colors.monoWhite)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _selectedImageBase64 = null),
                      child: Icon(CupertinoIcons.xmark_circle_fill, size: 12, color: colors.monoSecondary),
                    ),
                  ],
                ),
              ),
          ],
          Expanded(
            child: CupertinoTextField(
              controller: _promptController,
              placeholder: 'Ask LibreAI or describe image to generate...',
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(fontSize: 14, color: colors.monoWhite),
              placeholderStyle: TextStyle(color: colors.monoSecondary, fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.accentClay,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(CupertinoIcons.arrow_up, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
