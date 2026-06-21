import 'package:flutter/material.dart';

/// Цветовая палитра Gentleman OS.
/// Точно соответствует дизайн-макету: тёмный фон #1A1A1A, золотой акцент #C9A84C,
/// тёмные карточки #252525, текст белый/серый.
/// Вдохновение: Roetzel «Der Gentleman», Boyer — сдержанность, классика, качество.
abstract final class AppColors {
  // Seed для Material 3 ColorScheme (gold как seed)
  static const seed = Color(0xFFC9A84C);

  // Фоны (тёмная тема из макета)
  static const background = Color(0xFF1A1A1A);    // основной фон
  static const surface = Color(0xFF252525);        // карточки
  static const surfaceVariant = Color(0xFF2E2E2E); // вторичные карточки
  static const surfaceHigh = Color(0xFF333333);    // приподнятые элементы

  // Акцент — золотой из герба
  static const gold = Color(0xFFC9A84C);
  static const goldLight = Color(0xFFE0BE6E);
  static const goldDark = Color(0xFF9A7A2E);

  // Текст
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textDisabled = Color(0xFF616161);

  // Семантические
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFEF5350);

  // Outline
  static const outline = Color(0xFF404040);
  static const outlineVariant = Color(0xFF2E2E2E);
}
