import 'package:flutter/material.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';

/// Настроение маскота, производное от Gentleman Score.
enum MascotMood { neutral, pleased, proud }

/// Чистая функция: Score (0..100) → настроение маскота.
/// Вынесена отдельно для юнит-тестов (без зависимости от UI).
MascotMood moodFromScore(double score) {
  if (score >= 70) return MascotMood.proud;
  if (score >= 30) return MascotMood.pleased;
  return MascotMood.neutral;
}

/// Короткая фраза-реакция маскота под настроение.
String mascotPhrase(MascotMood mood) => switch (mood) {
      MascotMood.proud => 'Безупречно сегодня',
      MascotMood.pleased => 'Хороший прогресс',
      MascotMood.neutral => 'Начнём день',
    };

/// Аниме-маскот: стилизованный женский силуэт в золотом круге.
/// Рисуется через [CustomPainter] — не требует бинарных ассетов,
/// масштабируется без потери качества и безопасен для CI.
class MascotAvatar extends StatelessWidget {
  const MascotAvatar({
    super.key,
    this.size = 40,
    this.mood = MascotMood.neutral,
  });

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    // Насыщенность золота растёт с настроением.
    final glow = switch (mood) {
      MascotMood.proud => 0.30,
      MascotMood.pleased => 0.18,
      MascotMood.neutral => 0.10,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.gold.withValues(alpha: glow),
            AppColors.background.withValues(alpha: 0.0),
          ],
          radius: 0.85,
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: mood == MascotMood.proud ? 1.0 : 0.6),
          width: 1,
        ),
      ),
      child: CustomPaint(
        painter: _MascotSilhouettePainter(
          color: AppColors.gold.withValues(alpha: mood == MascotMood.proud ? 0.95 : 0.8),
        ),
        size: Size(size, size),
      ),
    );
  }
}

/// Рисует обобщённый женский силуэт (голова, длинные волосы, плечи) —
/// аккуратный, без деталей, в духе минималистичного маскота.
class _MascotSilhouettePainter extends CustomPainter {
  const _MascotSilhouettePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Волосы (обрамляют голову и спускаются на плечи) — рисуем первыми.
    final hair = Path()
      ..moveTo(w * 0.28, h * 0.42)
      ..cubicTo(w * 0.20, h * 0.30, w * 0.30, h * 0.12, w * 0.50, h * 0.14)
      ..cubicTo(w * 0.70, h * 0.12, w * 0.80, h * 0.30, w * 0.72, h * 0.42)
      ..lineTo(w * 0.78, h * 0.82)
      ..lineTo(w * 0.66, h * 0.78)
      ..lineTo(w * 0.62, h * 0.50)
      ..lineTo(w * 0.38, h * 0.50)
      ..lineTo(w * 0.34, h * 0.78)
      ..lineTo(w * 0.22, h * 0.82)
      ..close();
    canvas.drawPath(hair, paint);

    // Лицо/шея (вырезаем светлым кругом для контраста силуэта).
    final faceCut = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(w * 0.5, h * 0.34), w * 0.155, faceCut);

    // Плечи (трапеция снизу).
    final shoulders = Path()
      ..moveTo(w * 0.30, h * 0.98)
      ..lineTo(w * 0.38, h * 0.62)
      ..quadraticBezierTo(w * 0.50, h * 0.56, w * 0.62, h * 0.62)
      ..lineTo(w * 0.70, h * 0.98)
      ..close();
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(_MascotSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
