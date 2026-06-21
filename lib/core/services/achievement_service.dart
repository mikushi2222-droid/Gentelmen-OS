import 'package:gentleman_os/core/db/daos/habits_dao.dart';
import 'package:gentleman_os/core/db/daos/knowledge_dao.dart';
import 'package:gentleman_os/core/db/daos/outfit_dao.dart';
import 'package:gentleman_os/core/db/daos/rpg_dao.dart';
import 'package:gentleman_os/core/db/daos/wardrobe_dao.dart';

/// Проверяет достижения и разблокирует их при выполнении условий.
/// Вызывается после каждого ключевого действия пользователя.
class AchievementService {
  const AchievementService({
    required this.rpgDao,
    required this.wardrobeDao,
    required this.outfitDao,
    required this.knowledgeDao,
    required this.habitsDao,
  });

  final RpgDao rpgDao;
  final WardrobeDao wardrobeDao;
  final OutfitDao outfitDao;
  final KnowledgeDao knowledgeDao;
  final HabitsDao habitsDao;

  Future<void> checkAfterWardrobeAdd() async {
    final available = await wardrobeDao.getAvailable();
    if (available.length >= 1) await _unlock('first_item');
    if (available.length >= 10) await _unlock('ten_items');
    if (available.length >= 30) await _unlock('wardrobe_30');
  }

  Future<void> checkAfterOutfitSave() async {
    final outfits = await outfitDao.watchAll().first;
    if (outfits.length >= 1) await _unlock('first_outfit');
    if (outfits.length >= 5) await _unlock('five_outfits');
  }

  Future<void> checkAfterArticleRead() async {
    final xpEvents = await rpgDao.getAllXpEvents();
    final readingXp = xpEvents
        .where((e) => e.type == 3) // XpType.reading.index
        .fold(0, (sum, e) => sum + e.amount);
    // Each article gives 15 XP → 5 articles = 75 XP
    if (readingXp >= 75) await _unlock('bookworm_5');
  }

  Future<void> checkAfterHabitComplete(String habitId) async {
    final streak = await habitsDao.computeStreak(habitId);
    if (streak >= 7) await _unlock('streak_7');
    if (streak >= 30) await _unlock('streak_30');
  }

  Future<void> checkAfterLevelUp(int level) async {
    if (level >= 5) await _unlock('level_5');
    if (level >= 10) await _unlock('level_10');
  }

  Future<void> _unlock(String code) async {
    final existing = await rpgDao.getAchievementByCode(code);
    if (existing != null && !existing.unlocked) {
      await rpgDao.unlock(code, DateTime.now());
    }
  }
}
