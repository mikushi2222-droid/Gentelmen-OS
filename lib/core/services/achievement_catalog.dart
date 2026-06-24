/// Единый каталог достижений — источник правды для сидинга БД и для логики
/// разблокировки в [AchievementService].
///
/// Раньше коды задавались строковыми литералами и в сид-данных, и в сервисе,
/// что приводило к рассинхрону (например `ten_items` в сервисе против
/// `wardrobe_10` в БД) — и достижения молча не разблокировались. Теперь все
/// коды — это именованные константы: опечатка стала ошибкой компиляции.
abstract final class Achv {
  // Гардероб
  static const firstItem = 'first_item';
  static const wardrobe10 = 'wardrobe_10';
  static const wardrobe25 = 'wardrobe_25';

  // Образы
  static const firstOutfit = 'first_outfit';

  // Чтение
  static const bookworm5 = 'bookworm_5';
  static const bookworm10 = 'bookworm_10';

  // Привычки / стрик
  static const streak7 = 'streak_7';
  static const streak30 = 'streak_30';

  // Уровни
  static const level5 = 'level_5';
  static const level10 = 'level_10';

  // Прочее
  static const measureLogged = 'measure_logged';
  static const budgetMaster = 'budget_master';

  // Recovery
  static const firstCheckIn = 'first_check_in';

  /// Полный список для сидинга: (код, заголовок, описание).
  /// В каталог входят только реально достижимые ачивки — у каждой есть
  /// триггер в [AchievementService].
  static const List<(String code, String title, String description)> all = [
    (firstItem, 'Первая вещь', 'Добавил первую вещь в гардероб'),
    (wardrobe10, 'Гардероб×10', 'Добавил 10 вещей в гардероб'),
    (wardrobe25, 'Гардероб×25', 'Добавил 25 вещей в гардероб'),
    (firstOutfit, 'Первый образ', 'Собрал первый образ'),
    (bookworm5, 'Читатель', 'Прочитал 5 статей'),
    (bookworm10, 'Книжник', 'Прочитал 10 статей'),
    (streak7, 'Неделя', 'Активен 7 дней подряд'),
    (streak30, 'Месяц', 'Активен 30 дней подряд'),
    (level5, 'Уровень 5', 'Достиг 5-го уровня'),
    (level10, 'Уровень 10', 'Достиг 10-го уровня'),
    (measureLogged, 'Первый замер', 'Записал первые параметры'),
    (budgetMaster, 'Бюджет под контролем', 'Закрыл 5 покупок'),
    (firstCheckIn, 'Первый чек-ин', 'Заполнил первый ежедневный чек-ин самочувствия'),
  ];
}
