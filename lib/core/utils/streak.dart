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
