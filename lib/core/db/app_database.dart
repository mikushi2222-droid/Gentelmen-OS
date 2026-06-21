import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:gentleman_os/core/db/tables/clothing_items_table.dart';
import 'package:gentleman_os/core/db/tables/daily_missions_table.dart';
import 'package:gentleman_os/core/db/tables/habits_table.dart';
import 'package:gentleman_os/core/db/tables/knowledge_articles_table.dart';
import 'package:gentleman_os/core/db/tables/measurement_logs_table.dart';
import 'package:gentleman_os/core/db/tables/outfits_table.dart';
import 'package:gentleman_os/core/db/tables/purchase_wishes_table.dart';
import 'package:gentleman_os/core/db/tables/rpg_table.dart';
import 'package:gentleman_os/core/db/tables/user_profile_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfile,
    ClothingItems,
    Outfits,
    OutfitItems,
    WearLogs,
    MeasurementLogs,
    KnowledgeArticles,
    Habits,
    HabitLogs,
    XpEvents,
    Achievements,
    PurchaseWishes,
    DailyMissions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'gentleman_os'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          // миграции по версиям будут здесь
        },
      );

  Future<void> _seedInitialData() async {
    await _seedUserProfile();
    await _seedAchievements();
  }

  Future<void> _seedUserProfile() async {
    final now = DateTime.now();
    await into(userProfile).insert(
      UserProfileCompanion.insert(
        id: const Value(0),
        updatedAt: now,
      ),
    );
  }

  Future<void> _seedAchievements() async {
    final now = DateTime.now();
    final achievementData = [
      ('first_item', 'Первая вещь', 'Добавил первую вещь в гардероб'),
      ('first_outfit', 'Первый образ', 'Собрал первый образ'),
      ('wardrobe_10', 'Гардероб×10', 'Добавил 10 вещей в гардероб'),
      ('wardrobe_25', 'Гардероб×25', 'Добавил 25 вещей в гардероб'),
      ('streak_7', 'Неделя', 'Активен 7 дней подряд'),
      ('streak_30', 'Месяц', 'Активен 30 дней подряд'),
      ('bookworm_5', 'Читатель', 'Прочитал 5 статей'),
      ('bookworm_10', 'Книжник', 'Прочитал 10 статей'),
      ('budget_master', 'Бюджет под контролем', 'Закрыл 5 покупок в бюджете'),
      ('level_5', 'Уровень 5', 'Достиг 5-го уровня'),
      ('level_10', 'Уровень 10', 'Достиг 10-го уровня'),
      ('measure_logged', 'Первый замер', 'Записал первые параметры'),
      ('outfit_rated', 'Оценщик', 'Оценил образ после носки'),
    ];

    for (final (code, title, description) in achievementData) {
      await into(achievements).insert(
        AchievementsCompanion.insert(
          id: code,
          code: code,
          title: title,
          description: description,
        ),
      );
    }
  }
}
