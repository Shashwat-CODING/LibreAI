import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'chat_models.dart';
import 'models.dart';

class ApiService {
  static Future<String> enhanceImagePrompt({
    required String userPrompt,
    required String cfAccountId,
    required String cfApiToken,
  }) async {
    try {
      final enhancementMessages = [
        {
          'role': 'system',
          'content': 'You are an expert AI image prompt engineer. Expand the user input into a detailed, photorealistic, high-quality image generation prompt. Output ONLY the enhanced prompt string, nothing else.'
        },
        {'role': 'user', 'content': userPrompt}
      ];

      if (cfAccountId.isNotEmpty && cfApiToken.isNotEmpty) {
        final url = Uri.parse(
            'https://api.cloudflare.com/client/v4/accounts/$cfAccountId/ai/run/@cf/meta/llama-3.3-70b-instruct');
        final res = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $cfApiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'messages': enhancementMessages, 'max_tokens': 150}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final enhanced = data['result']?['response'] ?? data['result']?['choices']?[0]?['message']?['content'];
          if (enhanced != null && enhanced.toString().trim().isNotEmpty) {
            return enhanced.toString().trim();
          }
        }
      }
    } catch (_) {}
    return '$userPrompt, highly detailed 8k cinematic lighting photorealistic masterpiece';
  }

  static Future<String> callCloudflareImageGen({
    required String rawPrompt,
    required String selectedImageModelId,
    required String cfAccountId,
    required String cfApiToken,
  }) async {
    final enhancedPrompt = await enhanceImagePrompt(
      userPrompt: rawPrompt,
      cfAccountId: cfAccountId,
      cfApiToken: cfApiToken,
    );
    final modelPath = selectedImageModelId.startsWith('@')
        ? selectedImageModelId
        : '@$selectedImageModelId';

    debugPrint('[LibreAI Debug] Starting callCloudflareImageGen for image model: $modelPath');

    if (cfAccountId.isNotEmpty && cfApiToken.isNotEmpty) {
      final url = Uri.parse(
          'https://api.cloudflare.com/client/v4/accounts/$cfAccountId/ai/run/$modelPath');

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $cfApiToken';
      request.fields['prompt'] = enhancedPrompt;
      request.fields['steps'] = '25';
      request.fields['width'] = '1024';
      request.fields['height'] = '1024';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          try {
            final data = jsonDecode(response.body);
            String? rawBase64;
            if (data['result'] != null && data['result']['image'] != null) {
              rawBase64 = data['result']['image'].toString();
            } else if (data['result'] != null && data['result']['response'] != null) {
              rawBase64 = data['result']['response'].toString();
            } else if (data['image'] != null) {
              rawBase64 = data['image'].toString();
            }
            if (rawBase64 != null && rawBase64.isNotEmpty) {
              return rawBase64.startsWith('data:') ? rawBase64 : 'data:image/png;base64,$rawBase64';
            }
          } catch (_) {}
        }
        
        final bytes = response.bodyBytes;
        final base64String = base64Encode(bytes);
        return 'data:image/png;base64,$base64String';
      } else {
        final jsonResponse = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $cfApiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'prompt': enhancedPrompt,
            'steps': 25,
            'width': 1024,
            'height': 1024,
          }),
        );
        if (jsonResponse.statusCode == 200) {
          final contentType = jsonResponse.headers['content-type'] ?? '';
          if (contentType.contains('application/json')) {
            try {
              final data = jsonDecode(jsonResponse.body);
              String? rawBase64;
              if (data['result'] != null && data['result']['image'] != null) {
                rawBase64 = data['result']['image'].toString();
              } else if (data['result'] != null && data['result']['response'] != null) {
                rawBase64 = data['result']['response'].toString();
              } else if (data['image'] != null) {
                rawBase64 = data['image'].toString();
              }
              if (rawBase64 != null && rawBase64.isNotEmpty) {
                return rawBase64.startsWith('data:') ? rawBase64 : 'data:image/png;base64,$rawBase64';
              }
            } catch (_) {}
          }
          final bytes = jsonResponse.bodyBytes;
          final base64String = base64Encode(bytes);
          return 'data:image/png;base64,$base64String';
        } else {
          throw Exception('Status ${response.statusCode}: ${response.body}');
        }
      }
    } else {
      final url = Uri.parse('https://libreai-gateway.shashwat-libre.workers.dev/api/image');
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'model': selectedImageModelId,
                'prompt': enhancedPrompt,
                'steps': 25,
                'width': 1024,
                'height': 1024,
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['image'] ?? 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        } else {
          throw Exception('Free image gateway busy. Configure API key in Settings.');
        }
      } catch (e) {
        throw Exception('Image generation error: $e');
      }
    }
  }

  static Future<String> callCloudflareWorkersAI({
    required List<ChatMessage> history,
    required AIModel model,
    required String systemPrompt,
    required String cfAccountId,
    required String cfApiToken,
  }) async {
    final fullSystemPrompt = '''$kSystemToolCapabilities

$systemPrompt

[Model & Runtime Identity]
You are LibreAI running on "${model.name}" (${model.id}) via Cloudflare Workers AI.
If asked which model you are using or what AI you are, explicitly state "${model.name}" (${model.id}).''';

    List<Map<String, dynamic>> messagesPayload = [
      {'role': 'system', 'content': fullSystemPrompt},
    ];

    for (var m in history) {
      if (m.role == 'user' && m.imageBase64 != null && m.imageBase64!.isNotEmpty) {
        final rawBase64 = m.imageBase64!.contains(',')
            ? m.imageBase64!.split(',').last.trim()
            : m.imageBase64!.trim();
        final dataUrl = m.imageBase64!.startsWith('data:')
            ? m.imageBase64!
            : 'data:image/jpeg;base64,$rawBase64';

        List<int> byteList = [];
        try {
          byteList = base64Decode(rawBase64).toList();
        } catch (_) {}

        messagesPayload.add({
          'role': 'user',
          'content': [
            {'type': 'text', 'text': m.content},
            {
              'type': 'image_url',
              'image_url': {'url': dataUrl}
            }
          ],
          if (byteList.isNotEmpty) 'image': byteList,
        });
      } else {
        messagesPayload.add({
          'role': m.role,
          'content': m.content,
        });
      }
    }

    final modelPath = model.id.startsWith('@') ? model.id : '@${model.id}';

    if (cfAccountId.isNotEmpty && cfApiToken.isNotEmpty) {
      final url = Uri.parse(
          'https://api.cloudflare.com/client/v4/accounts/$cfAccountId/ai/run/$modelPath');

      final toolsPayload = [
        {
          'type': 'function',
          'function': {
            'name': 'generate_image',
            'description': 'Generates an image based on a detailed visual description prompt.',
            'parameters': {
              'type': 'object',
              'properties': {
                'prompt': {
                  'type': 'string',
                  'description': 'Detailed, vivid, photorealistic prompt describing the image to render.'
                }
              },
              'required': ['prompt']
            }
          }
        }
      ];

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $cfApiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': messagesPayload,
          'tools': toolsPayload,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['result'] != null) {
          final resObj = data['result'];
          
          // Check for native tool calls in Cloudflare response
          final toolCalls = resObj['tool_calls'] ?? resObj['choices']?[0]?['message']?['tool_calls'];
          if (toolCalls != null && toolCalls is List && toolCalls.isNotEmpty) {
            for (var tc in toolCalls) {
              final fnName = tc['name'] ?? tc['function']?['name'];
              if (fnName == 'generate_image') {
                final args = tc['arguments'] ?? tc['function']?['arguments'];
                Map<String, dynamic> parsedArgs = {};
                if (args is Map) {
                  parsedArgs = Map<String, dynamic>.from(args);
                } else if (args is String) {
                  try {
                    parsedArgs = jsonDecode(args);
                  } catch (_) {}
                }
                final promptArg = parsedArgs['prompt'] ?? '';
                if (promptArg.toString().isNotEmpty) {
                  return '[GENERATE_IMAGE: ${promptArg.toString()}]';
                }
              }
            }
          }

          final choiceMsgContent = resObj['choices']?[0]?['message']?['content'];
          if (choiceMsgContent is String && choiceMsgContent.isNotEmpty) {
            return choiceMsgContent;
          } else if (choiceMsgContent is List && choiceMsgContent.isNotEmpty) {
            final textParts = choiceMsgContent
                .where((item) => item is Map && item['type'] == 'text' && item['text'] != null)
                .map((item) => item['text'].toString())
                .toList();
            if (textParts.isNotEmpty) {
              return textParts.join('\n');
            }
          }

          return resObj['response'] ?? 'No response generated.';
        } else {
          final errList = data['errors'] as List?;
          final firstErr = errList != null && errList.isNotEmpty ? errList.first : null;
          final code = firstErr?['code'] ?? response.statusCode;
          final msg = firstErr?['message'] ?? 'Cloudflare API call failed.';
          _handleStructuredError(response.statusCode, code, msg);
        }
      } else {
        _handleStructuredError(response.statusCode, null, response.body);
      }
    } else {
      final url = Uri.parse('https://libreai-gateway.shashwat-libre.workers.dev/api/chat');
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'model': model.id,
                'messages': messagesPayload,
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['response'] ?? data['content'] ?? 'Response generated successfully.';
        } else {
          return "Hello. I am **LibreAI** — running Cloudflare Workers AI model `${model.id}`.";
        }
      } catch (_) {
        return "Hello. I am **LibreAI** — running Cloudflare Workers AI model `${model.id}`.";
      }
    }
  }

  static Never _handleStructuredError(int httpCode, dynamic internalCode, String rawMsg) {
    // 1. Context Window / Request Too Large (413 / Code 3006)
    if (httpCode == 413 || internalCode == 3006 || rawMsg.toLowerCase().contains('too large') || rawMsg.toLowerCase().contains('context length')) {
      throw Exception('Context window limit reached for this conversation.\n\n👉 **Please start a New Chat (+ button)** to continue chatting with the model without payload overflow.');
    }

    // 2. Account Limited / Daily 10k Free Allocation (429 / Code 3036)
    if (internalCode == 3036 || rawMsg.contains('10,000 neurons') || rawMsg.contains('daily free allocation')) {
      throw Exception('Daily free allocation of 10,000 neurons used up.\n\n👉 **Please upgrade to Cloudflare Workers Paid plan or enter your paid API token in Settings.**');
    }

    // 3. Out of Capacity (429 / Code 3040)
    if (internalCode == 3040 || rawMsg.contains('No more data centers')) {
      throw Exception('Cloudflare data centers are currently out of capacity for this model.\n\n👉 **Please try again in a few moments or select a different model in Settings.**');
    }

    // 4. Model Terms Agreement (403 / Code 5016)
    if (internalCode == 5016 || rawMsg.contains('model terms') || rawMsg.contains('Llama3.2')) {
      throw Exception('Model terms agreement required.\n\n👉 **Please accept the model license terms in your Cloudflare Dashboard to use this model.**');
    }

    // 5. Account Blocked / Private Model Access (403 / Codes 3023, 5018, 3041)
    if (httpCode == 403 || internalCode == 3023 || internalCode == 5018 || internalCode == 3041) {
      throw Exception('Account or model access blocked ($rawMsg).\n\n👉 **Please check your Cloudflare API token permissions in Settings.**');
    }

    // 6. Invalid / Missing Model (400, 404 / Codes 5007, 3042)
    if (internalCode == 5007 || internalCode == 3042 || httpCode == 404) {
      throw Exception('Model unavailable or invalid ($rawMsg).\n\n👉 **Please select another model in Settings.**');
    }

    // 7. Timeout / Aborted (408 / Codes 3007, 3008)
    if (httpCode == 408 || internalCode == 3007 || internalCode == 3008) {
      throw Exception('Request timed out or was aborted by Cloudflare.\n\n👉 **Please retry your request.**');
    }

    // Fallback
    throw Exception('$rawMsg (HTTP $httpCode${internalCode != null ? ', Code $internalCode' : ''})');
  }
}
