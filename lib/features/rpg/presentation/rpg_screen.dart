import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

class RpgScreen extends ConsumerWidget {
  const RpgScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: загружать реальный XP из репозитория
    final info = computeLevel(340);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gentleman RPG')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          // Главный уровень
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
                  Text(
                    'Уровень ${info.level}',
                    style: tt.headlineSmall,
                  ),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sectionGap),
          Text('Навыки', style: tt.titleMedium),
          const SizedBox(height: Spacing.sm),
          ...XpType.values.map((t) => _SkillTile(type: t, xp: 50)),
          const SizedBox(height: Spacing.sectionGap),
          Text('Достижения', style: tt.titleMedium),
          const SizedBox(height: Spacing.sm),
          _AchievementGrid(),
        ],
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
            width: 80,
            child: Text(type.label, style: tt.bodySmall),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: info.progress,
                  borderRadius: BorderRadius.circular(3),
                  minHeight: 6,
                  color: cs.primary,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('Lv${info.level}', style: tt.labelSmall),
        ],
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = [
      (code: 'first_item', title: 'Первая вещь', unlocked: false),
      (code: 'first_outfit', title: 'Первый образ', unlocked: false),
      (code: 'streak_7', title: 'Неделя', unlocked: false),
      (code: 'bookworm_5', title: 'Читатель', unlocked: false),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: items
          .map(
            (a) => _AchievementBadge(
              title: a.title,
              unlocked: a.unlocked,
            ),
          )
          .toList(),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.title, required this.unlocked});

  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
              title,
              style: tt.labelSmall?.copyWith(
                color: unlocked ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
