import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/daos/recovery_dao.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/recovery/domain/recovery_state.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _tag = 'Recovery';

/// Запись самочувствия за сегодня (реактивная).
final todayRecoveryProvider = StreamProvider<RecoveryLogsData?>((ref) {
  return ref.watch(recoveryDaoProvider).watchToday();
});

/// Статус восстановления на сегодня.
final recoveryStateProvider = Provider<RecoveryState>((ref) {
  final data = ref.watch(todayRecoveryProvider).asData?.value;
  return computeRecoveryState(data);
});

/// Сохраняет (upsert) дневник самочувствия за сегодня.
Future<void> saveRecoveryEntry({
  required RecoveryDao dao,
  required String? existingId,
  int? energyLevel,
  int? hungerLevel,
  double? sleepHours,
  int? stressLevel,
  int? waterMl,
  String? notes,
}) async {
  final id = existingId ?? _uuid.v4();
  final today = DateTime.now();
  final d = DateTime(today.year, today.month, today.day);
  await dao.upsert(
    RecoveryLogsCompanion.insert(
      id: id,
      date: d,
      energyLevel: Value(energyLevel),
      hungerLevel: Value(hungerLevel),
      sleepHours: Value(sleepHours),
      stressLevel: Value(stressLevel),
      waterMl: Value(waterMl),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
    ),
  );
  log.i(_tag, 'Recovery check-in saved id=$id');
}
