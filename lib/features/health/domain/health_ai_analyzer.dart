import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/health/domain/health_marker.dart';

/// Формирует ИИ-разбор показателей мужского здоровья через RouterAI с
/// веб-поиском: даёт развёрнутые, основанные на исследованиях рекомендации по
/// коррекции дефицитов (питание, добавки/дозировки, образ жизни).
///
/// Это образовательная информация на основе опубликованных исследований,
/// мета-анализов и клинических рекомендаций — не замена консультации врача.
class HealthAiAnalyzer {
  HealthAiAnalyzer(this.client);

  final RouterAiClient client;
  static const String _tag = 'HealthAI';

  Future<String> analyze(
    Map<HealthMarkerType, double> latest, {
    bool webSearch = true,
  }) async {
    if (latest.isEmpty) {
      return 'Нет данных для анализа. Внесите хотя бы один показатель.';
    }

    final lines = latest.entries.map((e) {
      final ref = e.key.reference;
      final status = markerStatus(e.key, e.value);
      final range = 'норма ${ref.min ?? '—'}–${ref.max ?? '∞'} ${e.key.unit}';
      return '- ${e.key.label}: ${e.value} ${e.key.unit} ($range; статус: ${status.label})';
    }).join('\n');

    log.i(_tag,
        'ИИ-анализ по ${latest.length} маркерам (webSearch=$webSearch)');

    return client.chat(
      temperature: 0.4,
      webSearch: webSearch,
      messages: [
        {
          'role': 'system',
          'content': '''
Ты — нутрициолог-консультант по мужскому здоровью с опорой на доказательную базу.
Отвечай по-русски, развёрнуто и практично. Для каждого отклонения от нормы:
1. Объясни, что означает показатель и чем грозит отклонение.
2. Дай конкретные рекомендации по коррекции, опираясь на проверенные исследования,
   мета-анализы, клинические гайдлайны и обобщённый опыт (отзывы, форумы):
   - питание (конкретные продукты),
   - добавки с типичными дозировками и формами (например, витамин D3 2000–4000 МЕ/сут,
     магний глицинат, цинк, омега-3 и т.п.) и как контролировать,
   - образ жизни (сон, силовые тренировки, стресс, солнце).
3. Указывай ориентиры по контролю (когда пересдать анализ).
Если используешь веб-источники — ссылайся на них.
В конце добавь короткую строку: что важно согласовать с врачом (особенно дозировки и
рецептурные препараты). Не выдумывай числа — если не уверен, так и скажи.''',
        },
        {
          'role': 'user',
          'content':
              'Проанализируй мои показатели и предложи план коррекции дефицитов:\n\n$lines',
        },
      ],
    );
  }
}
