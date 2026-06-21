import 'package:flutter/material.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => _buildTheme(Brightness.light);
  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    // Тёмная тема строится по макету вручную (не из seed),
    // чтобы точно воспроизвести цветовую схему дизайнера.
    final colorScheme = brightness == Brightness.dark
        ? _darkColorScheme()
        : ColorScheme.fromSeed(
            seedColor: AppColors.seed,
            brightness: brightness,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? AppColors.background
          : colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.5,
      ),
      textTheme: _buildTextTheme(colorScheme),
    );
  }

  static ColorScheme _darkColorScheme() => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.gold,
        onPrimary: Color(0xFF1A1A1A),
        primaryContainer: Color(0xFF2E2710),
        onPrimaryContainer: AppColors.goldLight,
        secondary: Color(0xFF9E9E9E),
        onSecondary: Color(0xFF1A1A1A),
        secondaryContainer: Color(0xFF2E2E2E),
        onSecondaryContainer: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        errorContainer: Color(0xFF4A1010),
        onErrorContainer: Color(0xFFFFB4AB),
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerLowest: AppColors.background,
        surfaceContainerLow: AppColors.surface,
        surfaceContainer: AppColors.surfaceVariant,
        surfaceContainerHigh: AppColors.surfaceHigh,
        surfaceContainerHighest: Color(0xFF3A3A3A),
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
        inversePrimary: AppColors.goldDark,
      );

  static TextTheme _buildTextTheme(ColorScheme cs) => TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          color: cs.onSurface,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: cs.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: cs.onSurface,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: cs.onSurface,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      );
}
