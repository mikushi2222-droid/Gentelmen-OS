import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/dashboard/domain/mission_generator.dart';

void main() {
  final today = DateTime(2024, 6, 21);

  group('generateDailyMissions', () {
    test('пустой гардероб — всегда миссия добавить вещь', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 0,
        articlesRead: 0,
      );
      expect(missions.any((m) => m.id.value.endsWith('_first_item')), isTrue);
    });

    test('возвращает максимум 3 миссии', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 0,
        articlesRead: 0,
      );
      expect(missions.length, lessThanOrEqualTo(3));
    });

    test('при выполненном замере нет фитнес-миссии', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: true,
        hasOutfitToday: false,
        wardrobeCount: 5,
        articlesRead: 0,
      );
      expect(missions.any((m) => m.id.value.endsWith('_measure')), isFalse);
    });

    test('при наличии гардероба и без образа — миссия Собрать образ', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 3,
        articlesRead: 0,
      );
      expect(missions.any((m) => m.id.value.endsWith('_outfit')), isTrue);
    });

    test('всегда есть миссия привычки если не набрали 3 до неё', () {
      // All four possible mission types compete for 3 slots.
      // With all active, habit should appear unless pushed out.
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: true,
        hasOutfitToday: true,
        wardrobeCount: 5,
        articlesRead: 1,
      );
      // Only habit mission is generated when all others are done
      expect(missions.any((m) => m.id.value.endsWith('_habit')), isTrue);
      expect(missions.length, 1);
    });

    test('уникальные id для каждого дня', () {
      final m1 = generateDailyMissions(
        date: DateTime(2024, 6, 21),
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 0,
        articlesRead: 0,
      );
      final m2 = generateDailyMissions(
        date: DateTime(2024, 6, 22),
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 0,
        articlesRead: 0,
      );
      final ids1 = m1.map((m) => m.id.value).toSet();
      final ids2 = m2.map((m) => m.id.value).toSet();
      expect(ids1.intersection(ids2), isEmpty);
    });

    test('прочитал статью → нет миссии чтения', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 5,
        articlesRead: 1,
      );
      expect(missions.any((m) => m.id.value.endsWith('_article')), isFalse);
    });

    test('нет недавних записей здоровья → появляется миссия здоровья', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: true,
        hasOutfitToday: true,
        wardrobeCount: 5,
        articlesRead: 1,
        hasHealthMarkerRecently: false,
      );
      expect(missions.any((m) => m.id.value.endsWith('_health')), isTrue);
    });

    test('образ сегодня уже есть → нет миссии образа', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: false,
        hasOutfitToday: true,
        wardrobeCount: 5,
        articlesRead: 0,
      );
      expect(missions.any((m) => m.id.value.endsWith('_outfit')), isFalse);
    });

    test('привычка всегда последняя в списке', () {
      for (final scenario in [
        (m: false, o: false, w: 0, a: 0, h: true),
        (m: true, o: true, w: 5, a: 1, h: false),
        (m: false, o: false, w: 5, a: 0, h: true),
      ]) {
        final missions = generateDailyMissions(
          date: today,
          hasMeasurementToday: scenario.m,
          hasOutfitToday: scenario.o,
          wardrobeCount: scenario.w,
          articlesRead: scenario.a,
          hasHealthMarkerRecently: scenario.h,
        );
        expect(missions.last.id.value, endsWith('_habit'),
            reason: 'scenario: $scenario');
      }
    });

    test('при всех активных условиях — ровно 3 миссии', () {
      // Conditionals: measure + first_item + article + health = 4,
      // but code does take(2) + habit → always 3.
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: false,
        hasOutfitToday: false,
        wardrobeCount: 0,
        articlesRead: 0,
        hasHealthMarkerRecently: false,
      );
      expect(missions.length, 3);
    });

    test('только одна условная + привычка → 2 миссии', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: true,
        hasOutfitToday: true,
        wardrobeCount: 5,
        articlesRead: 1,
        hasHealthMarkerRecently: false, // только health mission
      );
      expect(missions.length, 2);
      expect(missions[0].id.value, endsWith('_health'));
      expect(missions[1].id.value, endsWith('_habit'));
    });

    test('нет условных миссий → только привычка', () {
      final missions = generateDailyMissions(
        date: today,
        hasMeasurementToday: true,
        hasOutfitToday: true,
        wardrobeCount: 5,
        articlesRead: 1,
      );
      expect(missions.length, 1);
      expect(missions.single.id.value, endsWith('_habit'));
    });
  });
}
