import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/health_markers_table.dart';

part 'health_dao.g.dart';

@DriftAccessor(tables: [HealthMarkers])
class HealthDao extends DatabaseAccessor<AppDatabase> with _$HealthDaoMixin {
  HealthDao(super.db);

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

  Future<void> upsert(HealthMarkersCompanion entry) =>
      into(healthMarkers).insertOnConflictUpdate(entry);

  Future<void> remove(String id) =>
      (delete(healthMarkers)..where((t) => t.id.equals(id))).go();
}
