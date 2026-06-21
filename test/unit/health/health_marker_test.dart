import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/health/domain/health_marker.dart';

void main() {
  group('markerStatus', () {
    test('значение в норме → normal', () {
      // Тестостерон общий: норма 8.6–29
      expect(
        markerStatus(HealthMarkerType.testosteroneTotal, 18),
        HealthStatus.normal,
      );
    });

    test('значение чуть выше нормы → warning', () {
      // Глюкоза: норма 3.9–5.5, span=1.6, margin=0.24 → 5.5..5.74 warning
      expect(
        markerStatus(HealthMarkerType.glucose, 5.6),
        HealthStatus.warning,
      );
    });

    test('значение сильно выше нормы → risk', () {
      expect(
        markerStatus(HealthMarkerType.glucose, 9.0),
        HealthStatus.risk,
      );
    });

    test('ПСА в пределах нормы → normal', () {
      expect(markerStatus(HealthMarkerType.psa, 1.2), HealthStatus.normal);
    });

    test('высокий ПСА → risk', () {
      expect(markerStatus(HealthMarkerType.psa, 10.0), HealthStatus.risk);
    });

    test('маркер только с нижней границей (ЛПВП): низкий → риск', () {
      // hdl: min 1.0, max null. span = 1.0, margin = 0.15 → <0.85 risk
      expect(markerStatus(HealthMarkerType.hdl, 0.5), HealthStatus.risk);
      expect(markerStatus(HealthMarkerType.hdl, 0.9), HealthStatus.warning);
      expect(markerStatus(HealthMarkerType.hdl, 2.0), HealthStatus.normal);
    });

    test('низкий тестостерон → warning или risk', () {
      expect(
        markerStatus(HealthMarkerType.testosteroneTotal, 8.0),
        anyOf(HealthStatus.warning, HealthStatus.risk),
      );
      expect(
        markerStatus(HealthMarkerType.testosteroneTotal, 3.0),
        HealthStatus.risk,
      );
    });

    test('давление систолическое 118 → normal', () {
      expect(
        markerStatus(HealthMarkerType.bloodPressureSys, 118),
        HealthStatus.normal,
      );
    });
  });

  group('healthIndex', () {
    test('пустая карта → 0', () {
      expect(healthIndex({}), 0.0);
    });

    test('все в норме → 100', () {
      final idx = healthIndex({
        HealthMarkerType.testosteroneTotal: 18,
        HealthMarkerType.glucose: 4.8,
        HealthMarkerType.sleepHours: 8,
      });
      expect(idx, closeTo(100, 0.01));
    });

    test('все в риске → 0', () {
      final idx = healthIndex({
        HealthMarkerType.glucose: 12,
        HealthMarkerType.psa: 20,
      });
      expect(idx, closeTo(0, 0.01));
    });

    test('warning засчитывается за половину', () {
      // один normal + один warning → (1 + 0.5)/2*100 = 75
      final idx = healthIndex({
        HealthMarkerType.testosteroneTotal: 18, // normal
        HealthMarkerType.glucose: 5.6, // warning
      });
      expect(idx, closeTo(75, 0.5));
    });

    test('результат всегда в [0, 100]', () {
      final idx = healthIndex({
        for (final t in HealthMarkerType.values) t: 1000,
      });
      expect(idx, inInclusiveRange(0.0, 100.0));
    });
  });

  group('метаданные маркеров', () {
    test('у всех типов непустые label и unit', () {
      for (final t in HealthMarkerType.values) {
        expect(t.label, isNotEmpty, reason: t.name);
        expect(t.unit, isNotEmpty, reason: t.name);
        expect(t.hint, isNotEmpty, reason: t.name);
      }
    });

    test('у всех типов задана хотя бы одна граница референса', () {
      for (final t in HealthMarkerType.values) {
        final r = t.reference;
        expect(r.min != null || r.max != null, isTrue, reason: t.name);
      }
    });
  });
}
