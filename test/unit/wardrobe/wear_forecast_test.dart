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

  group('computeWearForecast — граничные значения (30/14 дней)', () {
    test('daysSince == 30 → soon (не today, нужно > 30)', () {
      final lastWorn = summerNow.subtract(const Duration(days: 30));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 5),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.soon);
    });

    test('daysSince == 31 → today', () {
      final lastWorn = summerNow.subtract(const Duration(days: 31));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 5),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.today);
    });

    test('daysSince == 14 → onRotation (не soon, нужно > 14)', () {
      final lastWorn = summerNow.subtract(const Duration(days: 14));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 5),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.onRotation);
    });

    test('daysSince == 15 → soon', () {
      final lastWorn = summerNow.subtract(const Duration(days: 15));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 5),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.soon);
    });
  });

  group('computeWearForecast — wearCount > 0 без lastWornAt', () {
    test('расчёт среднего: 60 дней / 3 носки = 20 дней → soon', () {
      final item = _item(
        season: Season.summer,
        wearCount: 3,
        createdAt: summerNow.subtract(const Duration(days: 60)),
      );
      final f = computeWearForecast(item: item, now: summerNow);
      expect(f.urgency, WearUrgency.soon);
    });

    test('расчёт среднего: 90 дней / 2 носки = 45 дней → today', () {
      final item = _item(
        season: Season.summer,
        wearCount: 2,
        createdAt: summerNow.subtract(const Duration(days: 90)),
      );
      final f = computeWearForecast(item: item, now: summerNow);
      expect(f.urgency, WearUrgency.today);
    });
  });

  group('computeWearForecast — весенние и осенние сезоны', () {
    test('весенняя вещь весной → не offSeason', () {
      final springNow = DateTime(2026, 4, 15);
      final f = computeWearForecast(
        item: _item(season: Season.spring),
        now: springNow,
      );
      expect(f.urgency, isNot(WearUrgency.offSeason));
    });

    test('осенняя вещь осенью → не offSeason', () {
      final autumnNow = DateTime(2026, 10, 15);
      final f = computeWearForecast(
        item: _item(season: Season.autumn),
        now: autumnNow,
      );
      expect(f.urgency, isNot(WearUrgency.offSeason));
    });

    test('весенняя вещь летом → offSeason', () {
      final f = computeWearForecast(
        item: _item(season: Season.spring),
        now: summerNow,
      );
      expect(f.urgency, WearUrgency.offSeason);
    });

    test('летняя вещь зимой → offSeason', () {
      final f = computeWearForecast(
        item: _item(season: Season.summer),
        now: winterNow,
      );
      expect(f.urgency, WearUrgency.offSeason);
    });
  });

  group('WearUrgencyX.isActionable', () {
    test('today и soon — actionable', () {
      expect(WearUrgency.today.isActionable, isTrue);
      expect(WearUrgency.soon.isActionable, isTrue);
    });

    test('onRotation, offSeason, retired — не actionable', () {
      expect(WearUrgency.onRotation.isActionable, isFalse);
      expect(WearUrgency.offSeason.isActionable, isFalse);
      expect(WearUrgency.retired.isActionable, isFalse);
    });
  });

  group('computeWearForecast — detail поле', () {
    test('onRotation с lastWornAt → detail содержит "дн. назад"', () {
      final lastWorn = summerNow.subtract(const Duration(days: 7));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 1),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.onRotation);
      expect(f.detail, contains('дн. назад'));
    });

    test('today с lastWornAt → detail содержит "дней в шкафу"', () {
      final lastWorn = summerNow.subtract(const Duration(days: 45));
      final f = computeWearForecast(
        item: _item(season: Season.summer, wearCount: 1),
        now: summerNow,
        lastWornAt: lastWorn,
      );
      expect(f.urgency, WearUrgency.today);
      expect(f.detail, contains('дней в шкафу'));
    });

    test('offSeason → detail содержит сезон', () {
      final f = computeWearForecast(
        item: _item(season: Season.winter),
        now: summerNow,
      );
      expect(f.urgency, WearUrgency.offSeason);
      expect(f.detail, isNotNull);
    });
  });
}
