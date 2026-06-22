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

    // Sync forecast — чистая функция, lastWornAt не нужен в сетке.
    final forecast = computeWearForecast(
      item: item,
      now: DateTime.now(),
      lastWornAt: null,
    );

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
            // ── Полоса прогноза носки ──────────────────────────────────
            _WearForecastStrip(forecast: forecast),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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

class _WearForecastStrip extends StatelessWidget {
  const _WearForecastStrip({required this.forecast});

  final WearForecast forecast;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (bg, fg, icon) = _style(forecast.urgency);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: bg,
      child: Row(
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              forecast.headline,
              style: tt.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static (Color bg, Color fg, IconData icon) _style(WearUrgency u) =>
      switch (u) {
        WearUrgency.today => (
            AppColors.gold.withValues(alpha: 0.22),
            AppColors.gold,
            Icons.wb_sunny_outlined,
          ),
        WearUrgency.soon => (
            AppColors.success.withValues(alpha: 0.18),
            AppColors.success,
            Icons.schedule_outlined,
          ),
        WearUrgency.onRotation => (
            const Color(0xFF4A5568).withValues(alpha: 0.35),
            const Color(0xFFB0BEC5),
            Icons.check_circle_outline,
          ),
        WearUrgency.offSeason => (
            const Color(0xFF2D3748).withValues(alpha: 0.5),
            const Color(0xFF718096),
            Icons.ac_unit_outlined,
          ),
        WearUrgency.retired => (
            const Color(0xFF2D3748).withValues(alpha: 0.4),
            const Color(0xFF718096),
            Icons.block_outlined,
          ),
      };
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imagePath != null) {
      final file = File(imagePath!);
      return file.existsSync()
          ? Image.file(file, fit: BoxFit.cover, width: double.infinity)
          : _Placeholder(cs: cs);
    }
    return _Placeholder(cs: cs);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerLow,
      child: Center(
        child: Icon(Icons.checkroom_outlined, size: 48, color: cs.outline),
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
