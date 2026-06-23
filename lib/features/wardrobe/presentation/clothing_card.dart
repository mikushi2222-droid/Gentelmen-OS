import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/wardrobe/domain/wear_forecast.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

class ClothingCard extends StatelessWidget {
  const ClothingCard({super.key, required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/wardrobe/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ItemImage(imagePath: item.imagePath),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.category.label,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.wearCount > 0)
                        _WearBadge(count: item.wearCount),
                    ],
                  ),
                  if (item.wearCount > 0) ...[
                    const SizedBox(height: 6),
                    _WearBar(
                      forecast: garmentWearForecast(
                        category: item.category,
                        wearCount: item.wearCount,
                        material: item.material,
                      ),
                    ),
                  ],
                  if (item.brand != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.brand!,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.gold.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imagePath != null) {
      // Без existsSync(): синхронный I/O на каждый кадр скролла даёт джанк.
      // Отсутствующий файл обрабатывается errorBuilder'ом.
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => _Placeholder(cs: cs),
      );
    }
    return _Placeholder(cs: cs);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: cs.surfaceContainerLow,
      child: Center(
        child: Icon(Icons.checkroom_outlined, size: 48, color: cs.outline),
      ),
    );
  }
}

/// Тонкая полоса износа на карточке вещи (тот же цветовой код, что и на
/// экране детали): спокойный → тревожный по мере приближения к ресурсу.
class _WearBar extends StatelessWidget {
  const _WearBar({required this.forecast});

  final WearForecast forecast;

  @override
  Widget build(BuildContext context) {
    final pct = forecast.wearPercent;
    final color = pct >= 80
        ? AppColors.error
        : pct >= 50
            ? AppColors.warning
            : AppColors.success;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: forecast.wearFraction,
        minHeight: 3,
        backgroundColor: AppColors.outline,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _WearBadge extends StatelessWidget {
  const _WearBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '×$count',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
