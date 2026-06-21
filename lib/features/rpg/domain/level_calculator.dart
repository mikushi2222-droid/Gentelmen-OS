import 'dart:math' as math;

import 'package:gentleman_os/shared/enums/xp_type.dart';

const _baseXp = 100;

/// Детерминированный расчёт уровня из суммарного XP.
/// Чистая функция — никаких зависимостей.
LevelInfo computeLevel(int totalXp) {
  var level = 1;
  var xpUsed = 0;

  while (true) {
    final needed = _xpForLevel(level);
    if (xpUsed + needed > totalXp) break;
    xpUsed += needed;
    level++;
  }

  final needed = _xpForLevel(level);
  final current = totalXp - xpUsed;
  final progress = needed > 0 ? current / needed : 1.0;

  return LevelInfo(
    level: level,
    totalXp: totalXp,
    xpInCurrentLevel: current,
    xpNeededForNextLevel: needed,
    progress: progress.clamp(0.0, 1.0),
  );
}

/// XP для следующего уровня (растущая кривая).
int _xpForLevel(int level) =>
    (_baseXp * math.pow(level, 1.5)).round();

/// Итоговый Gentleman Score (0..100) из компонентов активности.
double computeGentlemanScore({
  required int styleXpLast7d,
  required int fitnessXpLast7d,
  required int habitsCompleted,
  required int habitsTotal,
  required int articlesReadLast7d,
}) {
  double styleC = (styleXpLast7d / 50).clamp(0.0, 1.0);
  double fitnessC = (fitnessXpLast7d / 50).clamp(0.0, 1.0);
  double habitsC = habitsTotal > 0 ? habitsCompleted / habitsTotal : 0;
  double readC = (articlesReadLast7d / 3).clamp(0.0, 1.0);

  return ((styleC + fitnessC + habitsC + readC) / 4 * 100).clamp(0.0, 100.0);
}

/// XP по типам навыка → уровень навыка.
Map<XpType, LevelInfo> computeSkillLevels(Map<XpType, int> xpByType) {
  return {
    for (final e in xpByType.entries) e.key: computeLevel(e.value),
  };
}

class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.totalXp,
    required this.xpInCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.progress,
  });

  final int level;
  final int totalXp;
  final int xpInCurrentLevel;
  final int xpNeededForNextLevel;
  final double progress;
}
