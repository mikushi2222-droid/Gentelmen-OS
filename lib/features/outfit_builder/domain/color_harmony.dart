/// Оценка цветовой гармонии образа.
/// Философия: нейтральная палитра + один акцент. Roetzel: navy, серый,
/// белый, бежевый — универсальные базы. Manson: меньше стараний, больше смысла.

const _neutrals = {
  'navy', 'синий', 'dark blue',
  'grey', 'gray', 'серый',
  'black', 'чёрный',
  'white', 'белый',
  'beige', 'бежевый',
  'cream', 'кремовый',
  'brown', 'коричневый', 'chocolate', 'шоколадный',
  'charcoal', 'антрацит',
  'camel', 'кэмэл',
};

({double score, List<String> notes}) colorHarmonyScore(
  List<String?> colors,
  List<String> userColorPrefs,
) {
  if (colors.isEmpty || colors.every((c) => c == null)) {
    return (score: 0.6, notes: ['Цвета не указаны — нейтральная оценка']);
  }

  final normalized = colors
      .whereType<String>()
      .map((c) => c.toLowerCase().trim())
      .toList();

  final notes = <String>[];
  var score = 0.5;

  final neutralCount = normalized.where(_isNeutral).length;
  final accentCount = normalized.length - neutralCount;

  if (neutralCount == normalized.length) {
    score += 0.3;
    notes.add('Полностью нейтральная палитра — безопасный классический выбор (+)');
  } else if (neutralCount >= 1 && accentCount == 1) {
    score += 0.25;
    notes.add('Нейтральная база + один акцент — отличная гармония (+)');
  } else if (accentCount > 1) {
    score -= 0.2;
    notes.add('Несколько акцентных цветов одновременно — рискованно (−)');
  }

  // Предпочтения пользователя
  for (final pref in userColorPrefs) {
    if (normalized.any((c) => c.contains(pref.toLowerCase()))) {
      score += 0.1;
      notes.add('Любимый цвет "${pref}" присутствует в образе (+)');
      break;
    }
  }

  return (score: score.clamp(0.0, 1.0), notes: notes);
}

bool _isNeutral(String color) =>
    _neutrals.any((n) => color.contains(n));
