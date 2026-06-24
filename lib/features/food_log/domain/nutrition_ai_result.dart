/// Результат AI-анализа приёма пищи.
/// Все значения приблизительные — UI всегда показывает символ «~».
class NutritionAiResult {
  const NutritionAiResult({
    this.kcalEstimate,
    this.proteinLevel,
    this.processingLevel,
    this.satietyNote,
    this.insights = const [],
  });

  /// Приблизительные калории. null — AI не смог оценить.
  final int? kcalEstimate;

  /// 'adequate' | 'low' | 'high' — относительный уровень белка.
  final String? proteinLevel;

  /// 'whole' | 'minimal' | 'processed' | 'ultra-processed'.
  final String? processingLevel;

  /// Одно предложение о насыщении: «High satiety meal».
  final String? satietyNote;

  /// Короткие оперативные инсайты (1–3 строки).
  final List<String> insights;

  static const NutritionAiResult empty = NutritionAiResult();
}

/// Тип приёма пищи.
enum MealType {
  breakfast(0, 'Завтрак'),
  lunch(1, 'Обед'),
  dinner(2, 'Ужин'),
  snack(3, 'Перекус');

  const MealType(this.value, this.label);
  final int value;
  final String label;

  static MealType fromValue(int? v) => switch (v) {
        0 => breakfast,
        1 => lunch,
        2 => dinner,
        _ => snack,
      };
}
