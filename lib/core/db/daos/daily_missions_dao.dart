import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/daily_missions_table.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

part 'daily_missions_dao.g.dart';

@DriftAccessor(tables: [DailyMissions])
class DailyMissionsDao extends DatabaseAccessor<AppDatabase>
    with _$DailyMissionsDaoMixin {
  DailyMissionsDao(super.db);

  static const String _tag = 'Missions';

  Stream<List<DailyMissionsData>> watchForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(const Duration(days: 1));
    return (select(dailyMissions)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(day) &
                t.date.isSmallerThanValue(nextDay),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.xpType)]))
        .watch();
  }

  Future<List<DailyMissionsData>> getForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(const Duration(days: 1));
    return (select(dailyMissions)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(day) &
                t.date.isSmallerThanValue(nextDay),
          ))
        .get();
  }

  Future<void> upsertMission(DailyMissionsCompanion mission) {
    AppLogger.instance.i(_tag,
        'Миссия дня${mission.title.present ? ' «${mission.title.value}»' : ''}');
    return into(dailyMissions).insertOnConflictUpdate(mission);
  }

  Future<void> complete(String id) {
    AppLogger.instance.i(_tag, 'Миссия выполнена: $id');
    return (update(dailyMissions)..where((t) => t.id.equals(id))).write(
      DailyMissionsCompanion(
        completed: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }
}
