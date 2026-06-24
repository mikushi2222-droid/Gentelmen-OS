import 'package:gentleman_os/core/db/app_database.dart';

/// Операционный статус восстановления на сегодня.
enum RecoveryState {
  optimal('Optimal', 'Energy high, stress low — full capacity.'),
  stable('Stable', 'Baseline. Proceed with normal protocol.'),
  mildFatigue('Mild Fatigue', 'Reduce intensity. Prioritise protein and hydration.'),
  stressElevated('Stress Elevated', 'Avoid aggressive deficit. Focus on adherence.'),
  recoveryNeeded('Recovery Needed', 'Rest day recommended. Minimal compliance mode.');

  const RecoveryState(this.label, this.guidance);
  final String label;
  final String guidance;
}

/// Вычисляет статус восстановления из записи дневника.
/// Если данных нет — возвращает [RecoveryState.stable].
RecoveryState computeRecoveryState(RecoveryLogsData? data) {
  if (data == null) return RecoveryState.stable;

  final e = data.energyLevel ?? 3;
  final s = data.stressLevel ?? 2;
  final sl = data.sleepHours;

  // Штраф к энергии за недосып (< 6 ч = -2, < 7 ч = -1)
  final sleepPenalty = sl == null
      ? 0
      : sl < 6
          ? 2
          : sl < 7
              ? 1
              : 0;
  final effectiveEnergy = (e - sleepPenalty).clamp(1, 5);

  if (effectiveEnergy >= 4 && s <= 2) return RecoveryState.optimal;
  if (s >= 4) return RecoveryState.stressElevated;
  if (effectiveEnergy <= 1) return RecoveryState.recoveryNeeded;
  if (effectiveEnergy <= 2 || s >= 3) return RecoveryState.mildFatigue;
  return RecoveryState.stable;
}
