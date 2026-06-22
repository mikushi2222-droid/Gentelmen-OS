import 'package:drift/drift.dart' show Value;
import 'package:gentleman_os/core/db/app_database.dart';

/// Генерирует 3 ежедневные миссии на основе активности.
/// Вызывается при открытии дашборда.
List<DailyMissionsCompanion> generateDailyMissions({
  required DateTime date,
  required bool hasMeasurementToday,
  required bool hasOutfitToday,
  required int wardrobeCount,
  required int articlesRead,
  bool hasHealthMarkerRecently = true,
}) {
  final missions = <DailyMissionsCompanion>[];
  final day = DateTime(date.year, date.month, date.day);

  // Fitness mission
  if (!hasMeasurementToday) {
    missions.add(
      DailyMissionsCompanion(
        id: Value('${day.toIso8601String()}_measure'),
        date: Value(day),
        title: const Value('Записать замеры'),
        description: const Value('Зафиксируй вес и параметры тела'),
        xpReward: const Value(15),
        xpType: const Value(1), // fitness
        completed: const Value(false),
      ),
    );
  }

  // Style mission
  if (wardrobeCount == 0) {
    missions.add(
      DailyMissionsCompanion(
        id: Value('${day.toIso8601String()}_first_item'),
        date: Value(day),
        title: const Value('Добавить первую вещь'),
        description: const Value('Начни формировать свой цифровой гардероб'),
        xpReward: const Value(20),
        xpType: const Value(0), // style
        completed: const Value(false),
      ),
    );
  } else if (!hasOutfitToday) {
    missions.add(
      DailyMissionsCompanion(
        id: Value('${day.toIso8601String()}_outfit'),
        date: Value(day),
        title: const Value('Собрать образ'),
        description: const Value('Подбери и сохрани образ на сегодня'),
        xpReward: const Value(15),
        xpType: const Value(0), // style
        completed: const Value(false),
      ),
    );
  }

  // Reading mission
  if (articlesRead == 0) {
    missions.add(
      DailyMissionsCompanion(
        id: Value('${day.toIso8601String()}_article'),
        date: Value(day),
        title: const Value('Прочитать статью'),
        description: const Value('Открой базу знаний и прочти одну статью'),
        xpReward: const Value(10),
        xpType: const Value(3), // reading
        completed: const Value(false),
      ),
    );
  }

  // Health mission — once a week prompt to log health marker
  if (!hasHealthMarkerRecently) {
    missions.add(
      DailyMissionsCompanion(
        id: Value('${day.toIso8601String()}_health'),
        date: Value(day),
        title: const Value('Внести показатель здоровья'),
        description: const Value('Зафиксируй анализ или маркер здоровья'),
        xpReward: const Value(15),
        xpType: const Value(7), // health
        completed: const Value(false),
      ),
    );
  }

  // Grooming/Habit mission (always)
  missions.add(
    DailyMissionsCompanion(
      id: Value('${day.toIso8601String()}_habit'),
      date: Value(day),
      title: const Value('Выполнить привычки'),
      description: const Value('Отметь хотя бы одну ежедневную привычку'),
      xpReward: const Value(5),
      xpType: const Value(6), // general
      completed: const Value(false),
    ),
  );

  // Return max 3 missions
  return missions.take(3).toList();
}
