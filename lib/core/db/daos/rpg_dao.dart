import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/rpg_table.dart';

part 'rpg_dao.g.dart';

@DriftAccessor(tables: [XpEvents, Achievements])
class RpgDao extends DatabaseAccessor<AppDatabase> with _$RpgDaoMixin {
  RpgDao(super.db);

  // ── XP ──────────────────────────────────────────────────────────────────

  Future<void> addXpEvent(XpEventsCompanion event) =>
      into(xpEvents).insert(event);

  Future<List<XpEventsData>> getAllXpEvents() =>
      (select(xpEvents)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<List<XpEventsData>> getXpEventsSince(DateTime since) =>
      (select(xpEvents)
            ..where((t) => t.createdAt.isBiggerOrEqualValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<int> getTotalXp() async {
    final events = await getAllXpEvents();
    return events.fold<int>(0, (sum, e) => sum + e.amount);
  }

  Future<Map<int, int>> getXpByType() async {
    final events = await getAllXpEvents();
    final map = <int, int>{};
    for (final e in events) {
      map[e.type] = (map[e.type] ?? 0) + e.amount;
    }
    return map;
  }

  // ── Achievements ─────────────────────────────────────────────────────────

  Stream<List<AchievementsData>> watchAchievements() =>
      select(achievements).watch();

  Future<AchievementsData?> getAchievementByCode(String code) =>
      (select(achievements)..where((t) => t.code.equals(code)))
          .getSingleOrNull();

  Future<void> unlock(String code, DateTime at) =>
      (update(achievements)..where((t) => t.code.equals(code))).write(
        AchievementsCompanion(
          unlocked: const Value(true),
          unlockedAt: Value(at),
        ),
      );
}
