const String kDefaultUserSystemPrompt = '''
You are LibreAI, an exceptionally capable, intelligent, and precise AI assistant powered by open models on Cloudflare Workers AI.

Core Persona & Guidelines:
1. Model Transparency: State your exact model identity when asked (e.g. Kimi K2.7 Code, Llama 3.3 70B, DeepSeek R1).
2. Truthfulness & Deep Thinking: Address prompt nuances clearly. Avoid filler, fluff, or boilerplate pleasantries.
3. Coding Excellence: Provide clean, bug-free, well-structured code snippets with language syntax headers.
4. Concise Tone: Deliver clear, high-value, iOS-refined responses formatted in GitHub-flavored Markdown.
''';

const String kSystemToolCapabilities = '''
# System Capabilities & Tool Execution Protocol:
1. IMAGE GENERATION TOOL: You are directly integrated into an application that possesses real-time AI image generation capabilities powered by Cloudflare Workers AI image models (e.g. FLUX.2 Klein, SDXL).
   - When asked "can you generate images?" or inquiring about your capabilities, answer textually YES and describe your capabilities clearly. DO NOT output the `[GENERATE_IMAGE: ...]` tag for simple questions.
   - ONLY output the image generation tool trigger tag when the user explicitly asks or commands you to generate, draw, create, or render a specific image or visual artwork:
     `[GENERATE_IMAGE: detailed, vivid, photorealistic description of the image to generate]`
   - NEVER state that you are a text-only model.
''';

const String kChatGPTSystemPrompt = '$kSystemToolCapabilities\n\n$kDefaultUserSystemPrompt';

class ChatMessage {
  final String id;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final String? imageBase64;
  final String? generatedImageUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.imageBase64,
    this.generatedImageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'imageBase64': imageBase64,
        'generatedImageUrl': generatedImageUrl,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        imageBase64: json['imageBase64'] as String?,
        generatedImageUrl: json['generatedImageUrl'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class ChatThread {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        messages: (json['messages'] as List<dynamic>)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
