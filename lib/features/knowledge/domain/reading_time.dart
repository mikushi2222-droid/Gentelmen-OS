/// Оценка времени чтения статьи по тексту.
///
/// Чистая функция (без Flutter) — легко тестируется. Считаем по словам при
/// средней скорости 200 слов/мин, округляем вверх и зажимаем в 1..99 минут,
/// чтобы пустой/огромный текст не давал 0 или абсурдных значений.
int readingMinutes(String markdown, {int wordsPerMinute = 200}) {
  final words = markdown
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .length;
  if (words == 0) return 1;
  return (words / wordsPerMinute).ceil().clamp(1, 99);
}
