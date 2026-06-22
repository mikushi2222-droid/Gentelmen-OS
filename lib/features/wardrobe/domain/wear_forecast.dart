/// Прогноз износа вещи (Уровень 1 — Гардероб, дифференциатор).
/// Объяснимо и офлайн: износ = число носок / «ресурс» категории. Никакой «магии».
/// См. docs/16-vision-three-levels-and-biohacking.md.
library;

import 'dart:math' as math;

import 'package:gentleman_os/shared/enums/clothing_category.dart';

/// Результат прогноза износа.
class WearForecast {
  const WearForecast({
    required this.wearFraction,
    required this.remainingWears,
    this.remainingMonths,
    required this.explanation,
  });

  /// Доля износа, 0..1.
  final double wearFraction;

  /// Оставшиеся носки до заметного износа.
  final int remainingWears;

  /// Прогноз ресурса в месяцах (если известна частота носки), иначе null.
  final int? remainingMonths;

  /// Объяснение расчёта (принцип объяснимости).
  final List<String> explanation;

  /// Процент износа целым числом для UI.
  int get wearPercent => (wearFraction * 100).round();
}

/// Примерный ресурс категории — число носок до заметного износа.
int resourceWearsFor(ClothingCategory category) => switch (category) {
      ClothingCategory.shirt => 80,
      ClothingCategory.polo => 100,
      ClothingCategory.tShirt => 120,
      ClothingCategory.trousers => 150,
      ClothingCategory.jeans => 300,
      ClothingCategory.blazer => 200,
      ClothingCategory.jacket => 250,
      ClothingCategory.coat => 400,
      ClothingCategory.shoes => 500,
      ClothingCategory.accessory => 1000,
    };

/// Прогноз износа вещи по числу носок и категории.
/// [wearsPerMonth] (опц.) включает прогноз остатка ресурса в месяцах.
WearForecast garmentWearForecast({
  required ClothingCategory category,
  required int wearCount,
  double? wearsPerMonth,
}) {
  final resource = resourceWearsFor(category);
  final fraction = (wearCount / resource).clamp(0.0, 1.0);
  final remaining = math.max(0, resource - wearCount);
  final months = (wearsPerMonth != null && wearsPerMonth > 0)
      ? (remaining / wearsPerMonth).floor()
      : null;
  return WearForecast(
    wearFraction: fraction,
    remainingWears: remaining,
    remainingMonths: months,
    explanation: [
      'Ресурс категории «${category.label}»: $resource носок',
      'Сейчас: $wearCount носок (${(fraction * 100).round()}%)',
      if (months != null) 'При текущей частоте хватит ещё ~$months мес.',
    ],
  );
}
