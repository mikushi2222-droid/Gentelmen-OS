import 'package:flutter/material.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';

/// Карточка-плитка для хаб-экранов (Стиль / Тело / Разум).
/// Иконка + заголовок + подзаголовок + стрелка.
class ModuleCard extends StatelessWidget {
  const ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = iconColor ?? AppColors.gold;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: tt.titleSmall?.copyWith(color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
      ),
    );
  }
}
