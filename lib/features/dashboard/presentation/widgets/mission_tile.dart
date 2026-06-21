import 'package:flutter/material.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';

class MissionTile extends StatelessWidget {
  const MissionTile({
    required this.title,
    required this.xpReward,
    required this.completed,
    required this.xpTypeIndex,
    this.onTap,
    super.key,
  });

  final String title;
  final int xpReward;
  final bool completed;
  final int xpTypeIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _typeColor(xpTypeIndex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? cs.primary : cs.outline,
        ),
        title: Text(
          title,
          style: tt.bodyMedium?.copyWith(
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? cs.onSurfaceVariant : cs.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: typeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$xpReward XP',
                style:
                    tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ],
        ),
        onTap: completed ? null : onTap,
      ),
    );
  }

  Color _typeColor(int index) {
    return switch (index) {
      0 => AppColors.gold, // style
      1 => AppColors.success, // fitness
      2 => Colors.purpleAccent, // grooming
      3 => Colors.blueAccent, // reading
      4 => Colors.orangeAccent, // etiquette
      5 => Colors.tealAccent, // career
      _ => Colors.grey, // general
    };
  }
}
