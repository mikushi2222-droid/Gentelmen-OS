import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/health/domain/health_ai_analyzer.dart';
import 'package:gentleman_os/features/health/domain/health_marker.dart';

/// Все замеры здоровья (по убыванию даты).
final healthMarkersProvider = StreamProvider<List<HealthMarkersData>>(
  (ref) => ref.watch(healthDaoProvider).watchAll(),
);

/// Замеры конкретного типа (для графика динамики).
final healthMarkersByTypeProvider =
    StreamProvider.family<List<HealthMarkersData>, HealthMarkerType>(
  (ref, type) => ref.watch(healthDaoProvider).watchByType(type.index),
);

/// Последнее значение каждого типа маркера.
final latestHealthByTypeProvider =
    FutureProvider<Map<HealthMarkerType, double>>((ref) async {
  // Реагируем на изменения списка.
  ref.watch(healthMarkersProvider);
  final rows = await ref.watch(healthDaoProvider).latestByType();
  return {
    for (final e in rows.entries)
      if (e.key >= 0 && e.key < HealthMarkerType.values.length)
        HealthMarkerType.values[e.key]: e.value.value,
  };
});

/// Агрегированный индекс здоровья (0..100).
final healthIndexProvider = FutureProvider<double>((ref) async {
  final latest = await ref.watch(latestHealthByTypeProvider.future);
  return healthIndex(latest);
});

/// Последняя запись (включая дату) для каждого типа маркера.
final latestHealthRowsByTypeProvider =
    FutureProvider<Map<HealthMarkerType, HealthMarkersData>>((ref) async {
  ref.watch(healthMarkersProvider);
  final rows = await ref.watch(healthDaoProvider).latestByType();
  return {
    for (final e in rows.entries)
      if (e.key >= 0 && e.key < HealthMarkerType.values.length)
        HealthMarkerType.values[e.key]: e.value,
  };
});

/// Маркеры, по которым давно не вносились данные (просрочены).
final overdueMarkersProvider = FutureProvider<List<HealthMarkerType>>((ref) async {
  final rows = await ref.watch(latestHealthRowsByTypeProvider.future);
  final now = DateTime.now();
  return [
    for (final type in HealthMarkerType.values)
      if (rows[type] != null &&
          now.isAfter(rows[type]!.date
              .add(Duration(days: type.checkIntervalMonths * 30))))
        type,
  ];
});

/// ИИ-анализатор здоровья (доступен только при настроенном RouterAI).
final healthAiAnalyzerProvider = Provider<HealthAiAnalyzer?>((ref) {
  final client = ref.watch(routerAiClientProvider);
  return client == null ? null : HealthAiAnalyzer(client);
});

/// Результат ИИ-анализа последних показателей. Перезапускается через
/// ref.invalidate(healthAiAnalysisProvider) по кнопке.
final healthAiAnalysisProvider = FutureProvider.autoDispose<String>((ref) async {
  final analyzer = ref.watch(healthAiAnalyzerProvider);
  if (analyzer == null) {
    throw RouterAiException(
      'ИИ-советник не подключён. Откройте Настройки → ИИ-советник и введите ключ RouterAI.',
    );
  }
  final latest = await ref.watch(latestHealthByTypeProvider.future);
  return analyzer.analyze(latest);
});
