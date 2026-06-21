import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    required this.icon,
    required this.label,
    required this.route,
    super.key,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: tt.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
