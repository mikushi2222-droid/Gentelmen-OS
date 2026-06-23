import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/daos/health_dao.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/health/application/health_providers.dart';
import 'package:gentleman_os/features/health/domain/lab_ocr_parser.dart';
import 'package:gentleman_os/features/health/domain/lab_photo_analyzer.dart';
import 'package:uuid/uuid.dart';

/// Импорт анализов из фото бланка: распознаёт показатели через Router AI
/// (только API, своего оффлайн-движка нет), оставляет по одному актуальному
/// значению на показатель и СРАЗУ сохраняет их в БД (в `HealthMarkers`).
class LabImporter {
  LabImporter({required this.analyzer, required this.dao});

  final LabPhotoAnalyzer analyzer;
  final HealthDao dao;
  static const String _tag = 'LabImport';

  /// [imageBase64] — чистый base64 фото (без data-префикса).
  /// Возвращает сохранённые показатели (после дедупликации «оставляем
  /// актуальное»). Пустой список — ничего не распознано или ИИ недоступен.
  Future<List<LabResultDraft>> importFromPhoto({
    required String imageBase64,
    String mime = 'image/jpeg',
  }) async {
    final recognized =
        await analyzer.decode(imageBase64: imageBase64, mime: mime);
    final drafts = keepLatestPerType(recognized);

    for (final d in drafts) {
      await dao.upsert(
        HealthMarkersCompanion(
          id: Value(const Uuid().v4()),
          type: Value(d.type.index),
          value: Value(d.value),
          date: Value(d.takenAt ?? DateTime.now()),
          note: const Value('Распознано из фото (Router AI)'),
        ),
      );
    }

    log.i(_tag, 'Импортировано показателей из фото: ${drafts.length}');
    return drafts;
  }
}

/// Доступен только при подключённом RouterAI (есть распознаватель фото).
/// null → ИИ не настроен, импорт с фото недоступен (остаётся ручной ввод).
final labImporterProvider = Provider<LabImporter?>((ref) {
  final analyzer = ref.watch(labPhotoAnalyzerProvider);
  if (analyzer == null) return null;
  return LabImporter(analyzer: analyzer, dao: ref.watch(healthDaoProvider));
});
