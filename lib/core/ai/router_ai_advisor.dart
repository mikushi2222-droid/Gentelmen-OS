import 'dart:convert';

import 'package:gentleman_os/core/ai/ai_advisor.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

/// Реализация [AiAdvisor] поверх RouterAI. При любой ошибке деградирует
/// на оффлайн-[fallback] (LocalAiAdvisor), чтобы приложение не ломалось.
class RouterAiAdvisor implements AiAdvisor {
  RouterAiAdvisor({required this.client, required this.fallback});

  final RouterAiClient client;
  final AiAdvisor fallback;

  static const String _tag = 'RouterAdvisor';

  @override
  Future<StyleAdvice> getStyleAdvice({
    required List<ClothingItem> wardrobe,
    String? occasion,
  }) async {
    if (wardrobe.isEmpty) {
      return fallback.getStyleAdvice(wardrobe: wardrobe, occasion: occasion);
    }
    try {
      final inventory = wardrobe
          .map((i) => '- ${i.category.label}: ${i.name}'
              '${i.color != null ? ', цвет ${i.color}' : ''}'
              '${i.material != null ? ', ${i.material}' : ''}'
              '${i.wearCount > 0 ? ', надевалась ${i.wearCount}×' : ''}')
          .join('\n');

      final userPrompt = '''
Проанализируй мужской гардероб и дай совет по стилю.
Повод: ${occasion ?? 'повседневный'}.

Гардероб:
$inventory

Верни СТРОГО валидный JSON без markdown:
{"summary":"1-2 предложения","suggestions":["совет",...],"warnings":["предостережение",...],"score":<число 0-100>}''';

      final content = await client.chat(
        jsonMode: true,
        messages: [
          {
            'role': 'system',
            'content':
                'Ты — лаконичный мужской стилист в духе классической элегантности. Отвечай только валидным JSON на русском языке.',
          },
          {'role': 'user', 'content': userPrompt},
        ],
      );

      final map = jsonDecode(content) as Map<String, dynamic>;
      log.i(_tag, 'Стиль-совет получен от RouterAI');
      return StyleAdvice(
        summary: (map['summary'] as String?)?.trim() ?? '',
        suggestions: _stringList(map['suggestions']),
        warnings: _stringList(map['warnings']),
        score: (map['score'] as num?)?.toDouble(),
      );
    } on Object catch (err, st) {
      log.w(_tag, 'RouterAI недоступен, оффлайн-фолбэк', error: err);
      log.d(_tag, st.toString());
      return fallback.getStyleAdvice(wardrobe: wardrobe, occasion: occasion);
    }
  }

  @override
  Future<List<KnowledgeArticle>> recommendArticles({
    required List<KnowledgeArticle> articles,
    required List<ClothingItem> wardrobe,
    int limit = 3,
  }) {
    // Рекомендации статей оставляем оффлайн-движку: ему нужно вернуть
    // реальные объекты из БД, а не сгенерированный текст.
    return fallback.recommendArticles(
      articles: articles,
      wardrobe: wardrobe,
      limit: limit,
    );
  }

  static List<String> _stringList(Object? v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return const [];
  }
}
