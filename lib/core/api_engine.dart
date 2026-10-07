import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiEngine {
  static const Map<String, String> providerUrls = {
    'siliconflow': 'https://api.siliconflow.cn/v1',
    'deepseek': 'https://api.deepseek.com',
    'openrouter': 'https://openrouter.ai/api/v1',
    'groq': 'https://api.groq.com/openai/v1',
  };

  static String defaultModel(String type) {
    switch (type) {
      case 'siliconflow':
        return 'Qwen/Qwen2.5-7B-Instruct';
      case 'deepseek':
        return 'deepseek-chat';
      case 'groq':
        return 'llama-3.1-70b-versatile';
      case 'openrouter':
        return 'meta-llama/llama-3.1-8b-instruct:free';
      default:
        return 'gpt-3.5-turbo';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchModels(String type, String apiKey) async {
    final baseUrl = providerUrls[type];
    if (baseUrl == null) {
      throw Exception('暂不支持的 provider: $type');
    }
    final res = await http.get(
      Uri.parse('$baseUrl/models'),
      headers: {'Authorization': 'Bearer $apiKey'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('获取模型失败: HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final List models = data['data'] ?? [];
    return models.map<Map<String, dynamic>>((m) {
      final id = (m['id'] ?? m['name'] ?? '').toString();
      final lower = id.toLowerCase();
      final isFree = lower.contains('free') ||
          lower.contains('glm-4-flash') ||
          lower.contains('qwen2.5-7b');
      return {
        'id': id,
        'name': m['name'] ?? id,
        'isFree': isFree,
      };
    }).toList();
  }

  static Future<String> chat({
    required String pType,
    required String apiKey,
    required String modelId,
    required List<Map<String, String>> messages,
  }) async {
    final baseUrl = providerUrls[pType];
    if (baseUrl == null) {
      throw Exception('暂不支持的 provider: $pType');
    }

    for (int i = 1; i <= 3; i++) {
      try {
        final res = await http.post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': modelId,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 6000,
          }),
        ).timeout(const Duration(seconds: 90));

        if (res.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          return decoded['choices'][0]['message']['content'] ?? '';
        } else if (res.statusCode == 429) {
          throw Exception('API 限流');
        } else {
          throw Exception('HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}');
        }
      } catch (e) {
        if (i == 3) rethrow;
        await Future.delayed(Duration(seconds: i * 2));
      }
    }
    return '';
  }
}