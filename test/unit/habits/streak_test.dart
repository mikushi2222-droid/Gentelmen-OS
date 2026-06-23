import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/utils/streak.dart';

void main() {
  // Фиксированное «сегодня» — без переходов DST, чтобы тесты были
  // детерминированными.
  final now = DateTime(2026, 6, 16, 10, 30);
  DateTime day(int offset) => DateTime(2026, 6, 16 - offset);

  group('computeStreakDays', () {
    test('пустой список → 0', () {
      expect(computeStreakDays(const [], now: now), 0);
    });

    test('только сегодня → 1', () {
      expect(computeStreakDays([day(0)], now: now), 1);
    });

    test('три дня подряд, включая сегодня → 3', () {
      expect(computeStreakDays([day(0), day(1), day(2)], now: now), 3);
    });

    test('серия без сегодня, но со вчера → считается', () {
      expect(computeStreakDays([day(1), day(2)], now: now), 2);
    });

    test('последняя отметка позавчера (пропущено вчера) → 0', () {
      expect(computeStreakDays([day(2), day(3)], now: now), 0);
    });

    test('пропуск в середине прерывает серию (регрессия бага day-gap)', () {
      // Сегодня и позавчера, без вчера. Раньше алгоритм возвращал 2.
      expect(computeStreakDays([day(0), day(2)], now: now), 1);
    });

    test('дубликаты дат не раздувают серию', () {
      expect(
        computeStreakDays([day(0), day(0), day(1), day(1)], now: now),
        2,
      );
    });

    test('время суток в отметке игнорируется', () {
      expect(
        computeStreakDays(
          [DateTime(2026, 6, 16, 23, 59), DateTime(2026, 6, 15, 0, 1)],
          now: now,
        ),
        2,
      );
    });

    test('серия корректно переходит границу месяца', () {
      final julyNow = DateTime(2026, 7, 1, 8);
      expect(
        computeStreakDays(
          [DateTime(2026, 7, 1), DateTime(2026, 6, 30), DateTime(2026, 6, 29)],
          now: julyNow,
        ),
        3,
      );
    });
  });
}
