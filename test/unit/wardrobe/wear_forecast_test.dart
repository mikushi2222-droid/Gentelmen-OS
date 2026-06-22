import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/wardrobe/domain/wear_forecast.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

ClothingItem _item({
  Season season = Season.all,
  Condition condition = Condition.good,
  int wearCount = 0,
  DateTime? createdAt,
}) =>
    ClothingItem(
      id: 'test',
      name: 'Test',
      category: ClothingCategory.shirt,
      season: season,
      condition: condition,
      wearCount: wearCount,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
    );

void main() {
  // Июньская дата → лето
  final summerNow = DateTime(2026, 6, 15);
  // Январская дата → зима
  final winterNow = DateTime(2026, 1, 15);

  group('computeWearForecast — состояние', () {
    test('retired → WearUrgency.retired', () {
      final f = computeWearForecast(
        item: _item(condition: Condition.retired),
        now: summerNow,
      );
      expect(f.urgency, WearUrgency.retired);
    });
  });

  group('computeWearForecast — сезонность', () {
    test('летняя вещь летом → не offSeason', () {
      final f = computeWearForecast(
        item: _item(season: Season.summer),
        now: summerNow,
      );
      expect(f.urgency, isNot(WearUrgency.offSeason));
    });

    test('зимняя вещь летом → offSeason', () {
      final f = computeWearForecast(
        item: _item(season: Season.winter),
        now: summerNow,
      );
      expect(f.urgency, WearUrgency.offSeason);
    });

    test('всесезонная вещь всегда in season', () {
      final f = computeWearForecast(
        item: _item(season: Season.all),
        now: winterNow,
      );
      expect(f.urgency, isNot(WearUrgency.offSeason));
    });
  });

  group('computeWearForecast — срочность', () {
    test('не носил > 30 дней → today', () {
      final oldItem = _item(
        season: Season.summer,
        createdAt: DateTime(2026, 4, 1),
      );
      final f = computeWearForecast(item: oldItem, now: summerNow);
      expect(f.urgency, WearUrgency.today);
    });

    test('носил 20 дней назад → soon', () {
      final lastWorn = summerNow.subtract(const Duration(days: 20));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 1),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.soon);
    });

    test('носил 5 дней назад → onRotation', () {
      final lastWorn = summerNow.subtract(const Duration(days: 5));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 5),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.onRotation);
    });

    test('не носил ни разу, в сезоне → today (ещё не носил)', () {
      final newItem = _item(
        season: Season.summer,
        wearCount: 0,
        createdAt: DateTime(2026, 3, 1),
      );
      final f = computeWearForecast(item: newItem, now: summerNow);
      expect(f.urgency, WearUrgency.today);
      expect(f.detail, contains('Ещё не носил'));
    });
  });
}
