enum WishStatus {
  wish,
  planned,
  bought,
  rejected;

  String get label => switch (this) {
        WishStatus.wish => 'Хочу',
        WishStatus.planned => 'Планирую',
        WishStatus.bought => 'Куплено',
        WishStatus.rejected => 'Отклонено',
      };
}
