import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/health/domain/lab_ocr_parser.dart';

/// Распознаёт фото бланка анализов через мультимодальную модель Router AI и
/// возвращает черновики показателей для подтверждения пользователем.
///
/// Приватность: фото уходит в облако ТОЛЬКО по явному действию пользователя
/// (вызов [decode] из экрана «Распознать»). При любой ошибке возвращается
/// пустой список — экран деградирует на ручной ввод, приложение не падает.
///
/// Это образовательный инструмент, НЕ медицинская диагностика: значения
/// проверяет пользователь, интерпретирует врач.
class LabPhotoAnalyzer {
  LabPhotoAnalyzer(this.client);

  final RouterAiClient client;
  static const String _tag = 'LabAI';

  static const String _prompt = '''
На фото — бланк медицинских анализов. Извлеки показатели и верни СТРОГО валидный
JSON без markdown и пояснений — массив объектов вида:
[{"markerName":"название как в бланке","value":<число>,"unit":"единицы","takenAt":"YYYY-MM-DD","confidence":<0..1>}]
Правила: value — только число (десятичный разделитель — точка); takenAt — дата
забора, если видна, иначе опусти поле; не выдумывай показатели, которых нет на
фото; если значение нечитаемо — пропусти строку. Никакого текста вне JSON.''';

  /// [imageBase64] — чистый base64 фото (без data-префикса).
  Future<List<LabResultDraft>> decode({
    required String imageBase64,
    String mime = 'image/jpeg',
  }) async {
    log.i(_tag, 'Распознавание бланка анализов (${imageBase64.length} b64-симв.)');
    try {
      final content = await client.analyzeImage(
        prompt: _prompt,
        imageBase64: imageBase64,
        mime: mime,
      );
      final drafts = parseLabResults(content);
      log.i(_tag, 'Распознано показателей: ${drafts.length}');
      return drafts;
    } on Object catch (err, st) {
      log.w(_tag, 'Распознавание не удалось, ручной ввод', error: err);
      log.d(_tag, st.toString());
      return const [];
    }
  }
}
