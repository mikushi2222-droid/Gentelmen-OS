import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Круговой индикатор — Gentleman Score / навыки RPG.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    required this.score,
    required this.size,
    this.strokeWidth = 8,
    this.label,
    this.color,
    super.key,
  });

  final double score; // 0..100
  final double size;
  final double strokeWidth;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ringColor = color ?? cs.primary;
    final fraction = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction,
          color: ringColor,
          trackColor: cs.surfaceContainerHighest,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.round().toString(),
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * fraction, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}
