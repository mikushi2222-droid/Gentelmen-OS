import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/recovery/application/recovery_providers.dart';
import 'package:gentleman_os/features/recovery/domain/recovery_state.dart';
import 'package:gentleman_os/features/recovery/presentation/widgets/recovery_checkin_sheet.dart';

/// Карточка операционного статуса на Dashboard / Body Hub.
/// Показывает состояние из последнего чек-ина или кнопку «Проверить».
class RecoveryStatusCard extends ConsumerWidget {
  const RecoveryStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final dataAsync = ref.watch(todayRecoveryProvider);
    final state = ref.watch(recoveryStateProvider);
    final hasData = dataAsync.asData?.value != null;

    final stateColor = switch (state) {
      RecoveryState.optimal => AppColors.success,
      RecoveryState.stable => AppColors.gold,
      RecoveryState.mildFatigue => AppColors.warning,
      RecoveryState.stressElevated => AppColors.error,
      RecoveryState.recoveryNeeded => AppColors.error,
    };

    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: stateColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            // Индикатор состояния
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: stateColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasData ? Icons.monitor_heart : Icons.add_circle_outline,
                color: stateColor,
                size: 24,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Status',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    hasData ? state.label : 'No check-in today',
                    style: tt.titleSmall?.copyWith(color: stateColor),
                  ),
                  if (hasData)
                    Text(
                      state.guidance,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Кнопка чек-ина
            IconButton(
              icon: Icon(
                hasData ? Icons.edit_outlined : Icons.add,
                color: stateColor,
                size: 20,
              ),
              onPressed: () => _showCheckIn(context),
              tooltip: hasData ? 'Обновить' : 'Добавить',
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckIn(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RecoveryCheckInSheet(),
    );
  }
}
