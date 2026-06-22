/// Под-оценки Главной (Стиль/Здоровье/Биохакинг/Дисциплина) и «совет дня».
/// Чистые модель и функция без Flutter/БД — легко тестируются.
/// См. docs/16-vision-three-levels-and-biohacking.md (блоки 2 и 4 Главной).
library;

/// Одна под-оценка: имя и значение 0..100.
class SubScore {
  const SubScore(this.name, this.value);

  final String name;
  final int value;
}

/// Набор из четырёх под-оценок Главной.
class SubScores {
  const SubScores({
    required this.style,
    required this.health,
    required this.biohacking,
    required this.discipline,
  });

  final int style;
  final int health;
  final int biohacking;
  final int discipline;

  List<SubScore> get all => [
        SubScore('Стиль', style),
        SubScore('Здоровье', health),
        SubScore('Биохакинг', biohacking),
        SubScore('Дисциплина', discipline),
      ];

  /// Самое слабое звено — то, что сейчас ограничивает прогресс.
  SubScore get weakest =>
      all.reduce((a, b) => a.value <= b.value ? a : b);
}

/// Совет дня вытекает из самого слабого звена (объяснимо, без «магии»).
String dailyTip(SubScores scores) => switch (scores.weakest.name) {
      'Стиль' => 'Соберите образ на сегодня — это поднимет «Стиль».',
      'Здоровье' =>
        'Сделайте замер или короткую прогулку — «Здоровье» подрастёт.',
      'Биохакинг' =>
        'Загляните в протоколы биохакинга и выберите одно действие.',
      'Дисциплина' => 'Отметьте привычку — дисциплина решает больше таланта.',
      _ => 'Маленькое действие сегодня лучше идеального плана завтра.',
    };
