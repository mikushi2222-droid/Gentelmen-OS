import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/health_markers_table.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

part 'health_dao.g.dart';

@DriftAccessor(tables: [HealthMarkers])
class HealthDao extends DatabaseAccessor<AppDatabase> with _$HealthDaoMixin {
  HealthDao(super.db);

  static const String _tag = 'Health';

  Stream<List<HealthMarkersData>> watchAll() => (select(healthMarkers)
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();

  Stream<List<HealthMarkersData>> watchByType(int type) =>
      (select(healthMarkers)
            ..where((t) => t.type.equals(type))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<HealthMarkersData>> getAll() => (select(healthMarkers)
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();

  /// Последний замер каждого типа (для индекса здоровья и карточек).
  Future<Map<int, HealthMarkersData>> latestByType() async {
    final all = await getAll(); // уже отсортировано по дате убыв.
    final result = <int, HealthMarkersData>{};
    for (final row in all) {
      result.putIfAbsent(row.type, () => row);
    }
    return result;
  }

  Future<bool> hasRecentMarker(DateTime since) async {
    final row = await (select(healthMarkers)
          ..where((t) => t.date.isBiggerThanValue(since))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> upsert(HealthMarkersCompanion entry) {
    AppLogger.instance.i(_tag,
        'Сохранение маркера ${entry.id.present ? entry.id.value : '?'}'
        '${entry.type.present ? ' тип=${entry.type.value}' : ''}'
        '${entry.value.present ? ' значение=${entry.value.value}' : ''}');
    return into(healthMarkers).insertOnConflictUpdate(entry);
  }

  Future<void> remove(String id) {
    AppLogger.instance.i(_tag, 'Удаление маркера $id');
    return (delete(healthMarkers)..where((t) => t.id.equals(id))).go();
  }
}
