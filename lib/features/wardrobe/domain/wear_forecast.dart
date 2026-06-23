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

  /// Краткий человекочитаемый статус износа для UI.
  String get statusLabel {
    if (wearFraction >= 0.85) return 'Пора задуматься о замене';
    if (wearFraction >= 0.6) return 'Заметный износ';
    if (wearFraction >= 0.3) return 'Рабочее состояние';
    return 'Как новая';
  }
}

/// Множитель ресурса по ткани: плотные/прочные ткани (деним, кожа, шерсть,
/// твид, канвас) служат дольше, деликатные (шёлк, кашемир, вискоза, атлас) —
/// изнашиваются быстрее. 1.0 — неизвестно/нейтрально. Объяснимо и офлайн.
double fabricDurabilityFactor(String? material) {
  final m = material?.toLowerCase().trim() ?? '';
  if (m.isEmpty) return 1.0;
  const sturdy = [
    'деним', 'джинс', 'denim', 'кожа', 'leather', 'шерсть', 'wool',
    'твид', 'tweed', 'канвас', 'canvas', 'брезент',
  ];
  const delicate = [
    'шёлк', 'шелк', 'silk', 'кашемир', 'cashmere', 'вискоза', 'viscose',
    'атлас', 'сатин', 'satin',
  ];
  if (sturdy.any(m.contains)) return 1.3;
  if (delicate.any(m.contains)) return 0.75;
  return 1.0;
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

/// Средняя частота носки в месяц по дате покупки.
/// Календарные месяцы считаем по полям (год·12 + месяц), без `Duration` —
/// так нет сдвигов на переходах летнего времени (см. CLAUDE.md §7).
/// Возвращает null, если дата неизвестна, в будущем или носок ещё не было.
double? wearsPerMonthSince({
  required DateTime? purchaseDate,
  required int wearCount,
  DateTime? now,
}) {
  if (purchaseDate == null || wearCount <= 0) return null;
  final today = now ?? DateTime.now();
  final months =
      (today.year - purchaseDate.year) * 12 + (today.month - purchaseDate.month);
  if (months < 0) return null; // дата покупки в будущем — данных нет
  // Меньше календарного месяца владения считаем как один месяц,
  // чтобы не делить на ноль и не завышать частоту до бесконечности.
  return wearCount / (months == 0 ? 1 : months);
}

/// Прогноз износа вещи по числу носок, категории и (опц.) ткани.
/// [wearsPerMonth] (опц.) включает прогноз остатка ресурса в месяцах.
/// [material] (опц.) корректирует ресурс через [fabricDurabilityFactor].
WearForecast garmentWearForecast({
  required ClothingCategory category,
  required int wearCount,
  double? wearsPerMonth,
  String? material,
}) {
  final baseResource = resourceWearsFor(category);
  final factor = fabricDurabilityFactor(material);
  final resource = math.max(1, (baseResource * factor).round());
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
      'Ресурс категории «${category.label}»: $baseResource носок',
      if (factor != 1.0)
        'Поправка на ткань (${material!}): ×${factor.toStringAsFixed(2)} → $resource',
      'Сейчас: $wearCount носок (${(fraction * 100).round()}%)',
      if (months != null) 'При текущей частоте хватит ещё ~$months мес.',
    ],
  );
}
