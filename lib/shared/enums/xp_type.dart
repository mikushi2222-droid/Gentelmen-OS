enum XpType {
  style,     // 0
  fitness,   // 1
  etiquette, // 2
  reading,   // 3
  career,    // 4
  finance,   // 5
  general,   // 6
  health;    // 7 — мужское здоровье (трекинг анализов)

  String get label => switch (this) {
        XpType.style => 'Стиль',
        XpType.fitness => 'Форма',
        XpType.etiquette => 'Этикет',
        XpType.reading => 'Чтение',
        XpType.career => 'Карьера',
        XpType.finance => 'Финансы',
        XpType.general => 'Общее',
        XpType.health => 'Здоровье',
      };
}
