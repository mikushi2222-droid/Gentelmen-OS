import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/utils/streak.dart';

void main() {
  // Фиксированное «сегодня» — детерминированно, без DST.
  final now = DateTime(2026, 6, 16, 10, 30);
  DateTime day(int offset) => DateTime(2026, 6, 16 - offset);

  group('completionByDay', () {
    test('пустой список → 7 false', () {
      expect(completionByDay(const [], now: now), List.filled(7, false));
    });

    test('только сегодня → [0]=true, остальные false', () {
      final r = completionByDay([day(0)], now: now);
      expect(r[0], isTrue);
      expect(r.sublist(1), List.filled(6, false));
    });

    test('сегодня и 6 дней назад → крайние индексы', () {
      final r = completionByDay([day(0), day(6)], now: now);
      expect(r[0], isTrue);
      expect(r[6], isTrue);
      expect(r[1], isFalse);
    });

    test('несколько отметок в один день не дублируются', () {
      final r = completionByDay(
        [DateTime(2026, 6, 16, 8), DateTime(2026, 6, 16, 20)],
        now: now,
      );
      expect(r[0], isTrue);
      expect(r.where((e) => e).length, 1);
    });

    test('отметка старше 7 дней игнорируется', () {
      final r = completionByDay([day(7), day(10)], now: now);
      expect(r, List.filled(7, false));
    });

    test('кастомное число дней', () {
      final r = completionByDay([day(0), day(2)], days: 3, now: now);
      expect(r, [true, false, true]);
    });

    test('переход через границу месяца', () {
      final july1 = DateTime(2026, 7, 1, 12);
      // 30 июня = вчера
      final r = completionByDay([DateTime(2026, 6, 30)], now: july1);
      expect(r[1], isTrue);
    });
  });
}
