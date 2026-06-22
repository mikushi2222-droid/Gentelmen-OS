import 'package:flutter/material.dart';

/// Цветовая палитра Gentleman OS (премиальный стиль v2).
/// Тёмно-синий «cockpit»-фон #0B0F14, карточки #111827, шампань-золото #C8A76A,
/// тёплый светлый текст #F8F5F0. См. docs/16-vision-three-levels-and-biohacking.md.
/// Вдохновение: приборные панели дорогих часов/авто, Notion/Obsidian, премиальный
/// японский lifestyle. Имена констант стабильны — значения обновлены под v2.
abstract final class AppColors {
  // Seed для Material 3 ColorScheme (шампань-золото как seed)
  static const seed = Color(0xFFC8A76A);

  // Фоны (тёмно-синяя база v2)
  static const background = Color(0xFF0B0F14);    // основной фон
  static const surface = Color(0xFF111827);        // карточки
  static const surfaceVariant = Color(0xFF18202E); // вторичные карточки
  static const surfaceHigh = Color(0xFF1F2937);    // приподнятые элементы

  // Акцент — шампань-золото
  static const gold = Color(0xFFC8A76A);
  static const goldLight = Color(0xFFD9BE86);
  static const goldDark = Color(0xFFA8854C);

  // Текст
  static const textPrimary = Color(0xFFF8F5F0);
  static const textSecondary = Color(0xFF9AA1AC);
  static const textDisabled = Color(0xFF5B6470);

  // Семантические
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFEF5350);

  // Outline (с лёгким сине-стальным оттенком)
  static const outline = Color(0xFF2A3441);
  static const outlineVariant = Color(0xFF18202E);
}
