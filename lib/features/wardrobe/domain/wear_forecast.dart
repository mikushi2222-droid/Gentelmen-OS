import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

enum WearUrgency { today, soon, onRotation, offSeason, retired }

extension WearUrgencyX on WearUrgency {
  bool get isActionable =>
      this == WearUrgency.today || this == WearUrgency.soon;
}

class WearForecast {
  const WearForecast({
    required this.urgency,
    required this.headline,
    this.detail,
  });

  final WearUrgency urgency;
  final String headline;
  final String? detail;
}

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

  // Дней с последней носки (или с добавления, если не носил).
  final int daysSince;
  final bool neverWorn = item.wearCount == 0 && lastWornAt == null;

  if (lastWornAt != null) {
    daysSince = now.difference(lastWornAt).inDays.clamp(0, 9999);
  } else if (neverWorn) {
    daysSince = now.difference(item.createdAt).inDays.clamp(0, 9999);
  } else {
    // wearCount > 0, но лог не записан — оцениваем среднее.
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
