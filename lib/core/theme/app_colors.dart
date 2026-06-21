import 'package:flutter/material.dart';

/// Цветовая палитра Gentleman OS.
/// Вдохновение: Roetzel «Der Gentleman» — классика, сдержанность, качество.
/// Доминанта — глубокий navy/charcoal, акцент — тёплый gold/amber.
abstract final class AppColors {
  // Seed для Material 3 ColorScheme
  static const seed = Color(0xFF1A3A5C); // deep navy

  // Базовые (light)
  static const navy = Color(0xFF1A3A5C);
  static const charcoal = Color(0xFF2C3E50);
  static const slate = Color(0xFF4A5568);
  static const mist = Color(0xFF8899AA);

  // Акцент
  static const gold = Color(0xFFB8962E);
  static const amber = Color(0xFFD4AC3A);

  // Нейтральные
  static const cream = Color(0xFFF5F0E8);
  static const ivory = Color(0xFFFAF7F2);
  static const parchment = Color(0xFFEDE8DC);

  // Семантические
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF57F17);
  static const error = Color(0xFFC62828);
}
