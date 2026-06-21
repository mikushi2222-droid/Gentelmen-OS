import 'package:flutter/material.dart';

class MissionTile extends StatelessWidget {
  const MissionTile({
    required this.title,
    required this.xpReward,
    required this.completed,
    required this.xpType,
    this.onTap,
    super.key,
  });

  final String title;
  final int xpReward;
  final bool completed;
  final String xpType;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '+$xpReward XP',
            style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
          ),
        ),
        onTap: completed ? null : onTap,
      ),
    );
  }
}
