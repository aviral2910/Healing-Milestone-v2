import 'package:flutter/material.dart';

enum AppThemeType {
  goldenDark,
  lavenderDark,
  slateDark,
  goldenLight,
  lavenderLight,
  slateLight,
}

class ThemePalette {
  final AppThemeType type;
  final String name;
  final bool isDark;

  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentPrimary;
  final Color accentSecondary;

  const ThemePalette({
    required this.type,
    required this.name,
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentPrimary,
    required this.accentSecondary,
  });

  static const ThemePalette goldenDark = ThemePalette(
    type: AppThemeType.goldenDark,
    name: 'Golden Dark (Default)',
    isDark: true,
    background: Color(0xFF000000), // True OLED Black
    surface: Color(0xFF0F0F0F), // Deep Charcoal
    surfaceLight: Color(0xFF1E1E1E), // Lighter grey
    textPrimary: Color(0xFFF5F5F7), // Frost White
    textSecondary: Color(0xFFA1A1A6), // Titanium Silver
    accentPrimary: Color(0xFFD4AF37), // Premium Gold
    accentSecondary: Color(0xFF878681), // Natural Titanium
  );

  static const ThemePalette lavenderDark = ThemePalette(
    type: AppThemeType.lavenderDark,
    name: 'Lavender',
    isDark: true,
    background: Color(0xFF08040A), // Very dark lavender
    surface: Color(0xFF13091A), // Dark lavender surface
    surfaceLight: Color(0xFF251233),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA1A1A6),
    accentPrimary: Color(0xFF8C7A9E), // Soft muted lavender
    accentSecondary: Color(0xFF5E5E60),
  );

  static const ThemePalette slateDark = ThemePalette(
    type: AppThemeType.slateDark,
    name: 'Slate Dark',
    isDark: true,
    background: Color(0xFF030303), // Almost black with a tiny hint of cool grey
    surface: Color(0xFF111112), // Very dark slate surface
    surfaceLight: Color(0xFF1C1C1E),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA1A1A6),
    accentPrimary: Color(0xFF9E9E9E), // Muted neutral silver/slate
    accentSecondary: Color(0xFF5E5E60),
  );

  static const ThemePalette goldenLight = ThemePalette(
    type: AppThemeType.goldenLight,
    name: 'Golden Light',
    isDark: false,
    background: Color(0xFFF2F2F7), // Light clean grey background
    surface: Color(0xFFFFFFFF), // Pure white surface
    surfaceLight: Color(0xFFE5E5EA), // Light grey for elements
    textPrimary: Color(0xFF1C1C1E), // Near black text
    textSecondary: Color(0xFF8E8E93), // Mid grey
    accentPrimary: Color(0xFFD4AF37), // Premium Gold
    accentSecondary: Color(0xFFA1A1A6),
  );

  static const ThemePalette lavenderLight = ThemePalette(
    type: AppThemeType.lavenderLight,
    name: 'Lavender Light',
    isDark: false,
    background: Color(0xFFF9F7FC), // Very light lavender tint
    surface: Color(0xFFFFFFFF), // Pure white
    surfaceLight: Color(0xFFF0EBF5), // Slightly darker lavender grey
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF8E8E93),
    accentPrimary: Color(0xFF8C7A9E), // Soft muted lavender
    accentSecondary: Color(0xFFA1A1A6),
  );

  static const ThemePalette slateLight = ThemePalette(
    type: AppThemeType.slateLight,
    name: 'Slate Light',
    isDark: false,
    background: Color(0xFFF5F5F6), // Light cool grey
    surface: Color(0xFFFFFFFF), // Pure white
    surfaceLight: Color(0xFFEBEBEC), // Slightly darker slate grey
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF8E8E93),
    accentPrimary: Color(0xFF9E9E9E), // Muted neutral silver/slate
    accentSecondary: Color(0xFFA1A1A6),
  );

  static const List<ThemePalette> allThemes = [
    goldenDark,
    lavenderDark,
    slateDark,
    goldenLight,
    lavenderLight,
    slateLight,
  ];
}
