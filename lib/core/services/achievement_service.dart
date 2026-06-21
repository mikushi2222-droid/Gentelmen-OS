import 'package:gentleman_os/core/db/daos/habits_dao.dart';
import 'package:gentleman_os/core/db/daos/knowledge_dao.dart';
import 'package:gentleman_os/core/db/daos/measurement_dao.dart';
import 'package:gentleman_os/core/db/daos/outfit_dao.dart';
import 'package:gentleman_os/core/db/daos/purchases_dao.dart';
import 'package:gentleman_os/core/db/daos/rpg_dao.dart';
import 'package:gentleman_os/core/db/daos/wardrobe_dao.dart';
import 'package:gentleman_os/core/services/achievement_catalog.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';
import 'package:gentleman_os/shared/enums/wish_status.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

/// Проверяет достижения и разблокирует их при выполнении условий.
/// Вызывается после каждого ключевого действия пользователя.
///
/// Все коды достижений берутся из [Achv] — общего каталога, по которому
/// сидится БД. Это исключает рассинхрон кодов между сидом и логикой.
class AchievementService {
  const AchievementService({
    required this.rpgDao,
    required this.wardrobeDao,
    required this.outfitDao,
    required this.knowledgeDao,
    required this.habitsDao,
    required this.measurementDao,
    required this.purchasesDao,
  });

  final RpgDao rpgDao;
  final WardrobeDao wardrobeDao;
  final OutfitDao outfitDao;
  final KnowledgeDao knowledgeDao;
  final HabitsDao habitsDao;
  final MeasurementDao measurementDao;
  final PurchasesDao purchasesDao;

  Future<void> checkAfterWardrobeAdd() async {
    final available = await wardrobeDao.getAvailable();
    if (available.length >= 1) await _unlock(Achv.firstItem);
    if (available.length >= 10) await _unlock(Achv.wardrobe10);
    if (available.length >= 25) await _unlock(Achv.wardrobe25);
    await _checkLevel();
  }

  Future<void> checkAfterOutfitSave() async {
    final outfits = await outfitDao.watchAll().first;
    if (outfits.isNotEmpty) await _unlock(Achv.firstOutfit);
    await _checkLevel();
  }

  Future<void> checkAfterArticleRead() async {
    final xpEvents = await rpgDao.getAllXpEvents();
    final readingXp = xpEvents
        .where((e) => e.type == XpType.reading.index)
        .fold(0, (sum, e) => sum + e.amount);
    // Каждая статья даёт 15 XP → 5 статей = 75 XP, 10 статей = 150 XP.
    if (readingXp >= 75) await _unlock(Achv.bookworm5);
    if (readingXp >= 150) await _unlock(Achv.bookworm10);
    await _checkLevel();
  }

  Future<void> checkAfterMeasurement() async {
    final measurements = await measurementDao.getAll();
    if (measurements.isNotEmpty) await _unlock(Achv.measureLogged);
    await _checkLevel();
  }

  Future<void> checkAfterPurchaseStatusChange() async {
    final wishes = await purchasesDao.getAll();
    final bought =
        wishes.where((w) => w.status == WishStatus.bought.index).length;
    if (bought >= 5) await _unlock(Achv.budgetMaster);
  }

  Future<void> checkAfterHabitComplete(String habitId) async {
    final streak = await habitsDao.computeStreak(habitId);
    if (streak >= 7) await _unlock(Achv.streak7);
    if (streak >= 30) await _unlock(Achv.streak30);
    await _checkLevel();
  }

  /// Уровневые ачивки. Уровень вычисляется из суммарного XP, поэтому проверка
  /// выполняется после любого начисления XP (в конце остальных проверок).
  Future<void> _checkLevel() async {
    final totalXp = await rpgDao.getTotalXp();
    final level = computeLevel(totalXp).level;
    if (level >= 5) await _unlock(Achv.level5);
    if (level >= 10) await _unlock(Achv.level10);
  }

  Future<void> _unlock(String code) async {
    final existing = await rpgDao.getAchievementByCode(code);
    if (existing != null && !existing.unlocked) {
      await rpgDao.unlock(code, DateTime.now());
    }
  }
}
