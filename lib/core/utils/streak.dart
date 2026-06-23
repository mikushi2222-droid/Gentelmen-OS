/// Чистый расчёт длины «стрика» (серии подряд идущих дней) из дат отметок.
/// Вынесен из DAO, чтобы тривиально тестироваться без БД.
///
/// Правила:
/// - даты нормализуются до дня и дедуплицируются;
/// - серия активна, только если самая свежая отметка — сегодня или вчера
///   (послабление «или вчера» нужно лишь на старте: сегодня могло быть ещё
///   не отмечено);
/// - далее требуются строго последовательные календарные дни — любой пропуск
///   прерывает серию.
///
/// Использует календарную арифметику (`DateTime(y, m, d - 1)`), а не
/// `subtract(Duration(days: 1))`, поэтому корректно переносит границы
/// месяца/года и не ломается на переходах летнего времени.
int computeStreakDays(Iterable<DateTime> logDates, {DateTime? now}) {
  DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

  final dates = logDates.map(dayOnly).toSet().toList()
    ..sort((a, b) => b.compareTo(a));
  if (dates.isEmpty) return 0;

  final today = dayOnly(now ?? DateTime.now());

  var expected = today;
  final latest = dates.first;
  if (latest != today) {
    if (latest == prevDay(today)) {
      expected = latest;
    } else {
      return 0;
    }
  }

  var streak = 0;
  for (final date in dates) {
    if (date == expected) {
      streak++;
      expected = prevDay(expected);
    } else {
      break;
    }
  }
  return streak;
}

/// Для каждого из последних [days] дней — была ли хотя бы одна отметка.
/// Индекс 0 — сегодня, `[days-1]` — самый ранний день. Чистая функция:
/// календарная арифметика (`DateTime(y, m, d - i)`), без БД и DST-сдвигов.
List<bool> completionByDay(
  Iterable<DateTime> logDates, {
  int days = 7,
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  final dayStarts = [
    for (var i = 0; i < days; i++) DateTime(ref.year, ref.month, ref.day - i),
  ];
  final result = List<bool>.filled(days, false);
  for (final dt in logDates) {
    final d = DateTime(dt.year, dt.month, dt.day);
    for (var i = 0; i < days; i++) {
      if (d == dayStarts[i]) {
        result[i] = true;
        break;
      }
    }
  }
  return result;
}
