/// Два слоя прогноза носки вещи — объяснимо и офлайн.
///
/// 1. Urgency layer (computeWearForecast): «когда надеть» — сезон + дни в шкафу.
/// 2. Fraction layer (garmentWearForecast): «насколько износилась» — ресурс + ткань.
///
/// Оба возвращают [WearForecast]; каждый заполняет свои поля, оставляя
/// остальные в значении по умолчанию.
library;

import 'dart:math' as math;

import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Shared types
// ══════════════════════════════════════════════════════════════════════════════

enum WearUrgency { today, soon, onRotation, offSeason, retired }

extension WearUrgencyX on WearUrgency {
  bool get isActionable =>
      this == WearUrgency.today || this == WearUrgency.soon;
}

/// Результат прогноза носки — объединяет urgency-слой и fraction-слой.
class WearForecast {
  const WearForecast({
    this.urgency = WearUrgency.onRotation,
    this.headline = '',
    this.detail,
    this.wearFraction = 0.0,
    this.remainingWears = 0,
    this.remainingMonths,
    this.explanation = const [],
  });

  // ── Urgency layer ────────────────────────────────────────────────────────
  final WearUrgency urgency;
  final String headline;
  final String? detail;

  // ── Fraction layer ───────────────────────────────────────────────────────
  /// Доля износа, 0..1.
  final double wearFraction;

  /// Оставшиеся носки до заметного износа.
  final int remainingWears;

  /// Прогноз ресурса в месяцах (если известна частота носки), иначе null.
  final int? remainingMonths;

  /// Объяснение расчёта (принцип объяснимости).
  final List<String> explanation;

  // ── Computed ─────────────────────────────────────────────────────────────
  /// Процент износа целым числом для UI.
  int get wearPercent => (wearFraction * 100).round();

  /// Краткий человекочитаемый статус износа.
  String get statusLabel {
    if (wearFraction >= 0.85) return 'Пора задуматься о замене';
    if (wearFraction >= 0.6) return 'Заметный износ';
    if (wearFraction >= 0.3) return 'Рабочее состояние';
    return 'Как новая';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 1. Urgency layer — computeWearForecast
// ══════════════════════════════════════════════════════════════════════════════

Season _currentSeason(DateTime date) {
  final m = date.month;
  if (m >= 3 && m <= 5) return Season.spring;
  if (m >= 6 && m <= 8) return Season.summer;
  if (m >= 9 && m <= 11) return Season.autumn;
  return Season.winter;
}

String _seasonAdverb(Season s) => switch (s) {
      Season.spring => 'весной',
      Season.summer => 'летом',
      Season.autumn => 'осенью',
      Season.winter => 'зимой',
      Season.all => '',
    };

/// Чистая функция — тестируемо без Flutter/Drift.
///
/// [lastWornAt] — дата последней носки из WearLogs; null, если нет записей.
WearForecast computeWearForecast({
  required ClothingItem item,
  required DateTime now,
  DateTime? lastWornAt,
}) {
  if (item.condition == Condition.retired) {
    return const WearForecast(
      urgency: WearUrgency.retired,
      headline: 'Списана',
      detail: 'Вещь снята с использования',
    );
  }

  final currentSeason = _currentSeason(now);
  final inSeason =
      item.season == Season.all || item.season == currentSeason;

  if (!inSeason) {
    final adverb = _seasonAdverb(item.season);
    return WearForecast(
      urgency: WearUrgency.offSeason,
      headline: 'Не сезон',
      detail: adverb.isNotEmpty ? 'Актуально $adverb' : null,
    );
  }

  final int daysSince;
  final bool neverWorn = item.wearCount == 0 && lastWornAt == null;

  if (lastWornAt != null) {
    daysSince = now.difference(lastWornAt).inDays.clamp(0, 9999);
  } else if (neverWorn) {
    daysSince = now.difference(item.createdAt).inDays.clamp(0, 9999);
  } else {
    final totalDays = now.difference(item.createdAt).inDays;
    daysSince =
        item.wearCount > 0 ? (totalDays ~/ item.wearCount) : totalDays;
  }

  if (daysSince > 30) {
    return WearForecast(
      urgency: WearUrgency.today,
      headline: 'Надень сегодня!',
      detail: neverWorn ? 'Ещё не носил' : '$daysSince дней в шкафу',
    );
  }

  if (daysSince > 14) {
    return WearForecast(
      urgency: WearUrgency.soon,
      headline: 'Пора надеть',
      detail: '$daysSince дн. в шкафу',
    );
  }

  return WearForecast(
    urgency: WearUrgency.onRotation,
    headline: 'В ротации',
    detail: lastWornAt != null ? '$daysSince дн. назад' : null,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. Fraction layer — garmentWearForecast
// ══════════════════════════════════════════════════════════════════════════════

/// Множитель ресурса по ткани: плотные ткани служат дольше, деликатные — нет.
/// 1.0 — неизвестно/нейтрально.
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
/// так нет сдвигов на переходах летнего времени.
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
  if (months < 0) return null;
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

  final urgency = fraction >= 0.85
      ? WearUrgency.today
      : fraction >= 0.6
          ? WearUrgency.soon
          : WearUrgency.onRotation;

  return WearForecast(
    urgency: urgency,
    headline: _fractionHeadline(fraction),
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

String _fractionHeadline(double fraction) {
  if (fraction >= 0.85) return 'Пора задуматься о замене';
  if (fraction >= 0.6) return 'Заметный износ';
  if (fraction >= 0.3) return 'Рабочее состояние';
  return 'Как новая';
}
