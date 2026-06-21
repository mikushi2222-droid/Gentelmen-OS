enum XpType {
  style,
  fitness,
  etiquette,
  reading,
  career,
  finance,
  general;

  String get label => switch (this) {
        XpType.style => 'Стиль',
        XpType.fitness => 'Форма',
        XpType.etiquette => 'Этикет',
        XpType.reading => 'Чтение',
        XpType.career => 'Карьера',
        XpType.finance => 'Финансы',
        XpType.general => 'Общее',
      };
}
