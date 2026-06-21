import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
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
