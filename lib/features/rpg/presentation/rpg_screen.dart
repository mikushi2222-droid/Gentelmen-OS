import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/rpg/application/rpg_providers.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

class RpgScreen extends ConsumerWidget {
  const RpgScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLevel = ref.watch(rpgLevelInfoProvider);
    final asyncXpByType = ref.watch(rpgXpByTypeProvider);
    final asyncAchievements = ref.watch(rpgAchievementsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gentleman RPG')),
      body: asyncLevel.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (info) => ListView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.cardPadding),
                child: Column(
                  children: [
                    ScoreRing(
                      score: info.progress * 100,
                      size: 120,
                      label: 'LVL ${info.level}',
                      color: cs.primary,
                    ),
                    const SizedBox(height: Spacing.md),
                    Text('Уровень ${info.level}', style: tt.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${info.xpInCurrentLevel} / ${info.xpNeededForNextLevel} XP',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: Spacing.sm),
                    LinearProgressIndicator(
                      value: info.progress,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Всего XP: ${info.totalXp}',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.sectionGap),
            Text('Навыки', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            asyncXpByType.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox(),
              data: (xpMap) => Column(
                children: XpType.values.map((t) {
                  final xp = xpMap[t.index] ?? 0;
                  return _SkillTile(type: t, xp: xp);
                }).toList(),
              ),
            ),
            const SizedBox(height: Spacing.sectionGap),
            Text('Достижения', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            asyncAchievements.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox(),
              data: (list) => _AchievementGrid(achievements: list),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.type, required this.xp});

  final XpType type;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final info = computeLevel(xp);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(type.label, style: tt.bodySmall),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: info.progress,
              borderRadius: BorderRadius.circular(3),
              minHeight: 6,
              color: cs.primary,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('Lv${info.level}', style: tt.labelSmall),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$xp XP',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid({required this.achievements});

  final List<AchievementsData> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Достижения загружаются...'),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (ctx, i) => _AchievementBadge(achievement: achievements[i]),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final AchievementsData achievement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unlocked = achievement.unlocked;

    return Tooltip(
      message: achievement.description,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: unlocked ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked ? cs.primary : cs.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.lock_outline,
              color: unlocked ? cs.onPrimaryContainer : cs.outline,
              size: 32,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                achievement.title,
                style: tt.labelSmall?.copyWith(
                  color: unlocked
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
