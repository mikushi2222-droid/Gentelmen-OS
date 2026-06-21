enum Occasion {
  everyday,
  work,
  business,
  formal,
  smartCasual,
  sport,
  date,
  travel;

  String get label => switch (this) {
        Occasion.everyday => 'Каждый день',
        Occasion.work => 'Работа',
        Occasion.business => 'Деловая встреча',
        Occasion.formal => 'Официальное',
        Occasion.smartCasual => 'Smart Casual',
        Occasion.sport => 'Спорт',
        Occasion.date => 'Свидание',
        Occasion.travel => 'Путешествие',
      };

  int get formalityLevel => switch (this) {
        Occasion.sport => 0,
        Occasion.everyday => 1,
        Occasion.travel => 1,
        Occasion.date => 2,
        Occasion.smartCasual => 2,
        Occasion.work => 3,
        Occasion.business => 4,
        Occasion.formal => 5,
      };
}
