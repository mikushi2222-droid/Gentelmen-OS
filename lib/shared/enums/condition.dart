enum Condition {
  brandNew,
  good,
  worn,
  retired;

  String get label => switch (this) {
        Condition.brandNew => 'Новая',
        Condition.good => 'Хорошее',
        Condition.worn => 'Поношена',
        Condition.retired => 'Выведена',
      };
}
