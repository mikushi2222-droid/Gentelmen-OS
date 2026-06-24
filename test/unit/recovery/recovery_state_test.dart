import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/recovery/domain/recovery_state.dart';
import 'package:gentleman_os/core/db/app_database.dart';

// Minimal stub: only the fields used by computeRecoveryState.
class _MockRecovery implements RecoveryLogsData {
  _MockRecovery({this.energyLevel, this.stressLevel, this.sleepHours});

  @override
  final int? energyLevel;
  @override
  final int? stressLevel;
  @override
  final double? sleepHours;

  @override
  String get id => 'mock';
  @override
  DateTime get date => DateTime(2026, 1, 1);
  @override
  int? get hungerLevel => null;
  @override
  int? get waterMl => null;
  @override
  int? get steps => null;
  @override
  String? get notes => null;
}

void main() {
  group('computeRecoveryState', () {
    test('null input → stable', () {
      expect(computeRecoveryState(null), RecoveryState.stable);
    });

    test('energy=5, stress=1, sleep=8 → optimal', () {
      final r = _MockRecovery(energyLevel: 5, stressLevel: 1, sleepHours: 8);
      expect(computeRecoveryState(r), RecoveryState.optimal);
    });

    test('energy=4, stress=2, no sleep → optimal', () {
      final r = _MockRecovery(energyLevel: 4, stressLevel: 2);
      expect(computeRecoveryState(r), RecoveryState.optimal);
    });

    test('stress=4 → stressElevated независимо от энергии', () {
      final r = _MockRecovery(energyLevel: 5, stressLevel: 4, sleepHours: 8);
      expect(computeRecoveryState(r), RecoveryState.stressElevated);
    });

    test('stress=5 → stressElevated', () {
      final r = _MockRecovery(energyLevel: 3, stressLevel: 5);
      expect(computeRecoveryState(r), RecoveryState.stressElevated);
    });

    test('energy=2, sleep=8, stress=2 → mildFatigue', () {
      final r = _MockRecovery(energyLevel: 2, stressLevel: 2, sleepHours: 8);
      expect(computeRecoveryState(r), RecoveryState.mildFatigue);
    });

    test('energy=3, sleep=5 → recoveryNeeded (effectiveEnergy=1)', () {
      // sleep < 6 → sleepPenalty=2, effectiveEnergy=3-2=1
      final r = _MockRecovery(energyLevel: 3, stressLevel: 1, sleepHours: 5.5);
      expect(computeRecoveryState(r), RecoveryState.recoveryNeeded);
    });

    test('energy=3, sleep=6.5 → mildFatigue (effectiveEnergy=2)', () {
      // sleep < 7 → sleepPenalty=1, effectiveEnergy=3-1=2
      final r = _MockRecovery(energyLevel: 3, stressLevel: 2, sleepHours: 6.5);
      expect(computeRecoveryState(r), RecoveryState.mildFatigue);
    });

    test('energy=3, sleep=7.5, stress=2 → stable', () {
      final r = _MockRecovery(energyLevel: 3, stressLevel: 2, sleepHours: 7.5);
      expect(computeRecoveryState(r), RecoveryState.stable);
    });
  });

  group('RecoveryState.label', () {
    test('все состояния имеют непустой label и guidance', () {
      for (final s in RecoveryState.values) {
        expect(s.label, isNotEmpty);
        expect(s.guidance, isNotEmpty);
      }
    });
  });
}
