import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_palette.dart';

class AppTheme {
  // We keep the old static constants pointing to the default Golden Dark for any legacy code,
  // but ideally widgets should start using Theme.of(context).
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA1A1A6);
  static const Color accentPrimary = Color(0xFFD4AF37);
  static const Color accentSecondary = Color(0xFF878681);

  static ThemeData getThemeData(ThemePalette palette) {
    final baseTextTheme = GoogleFonts.outfitTextTheme(palette.isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme);

    return (palette.isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.accentPrimary,
      colorScheme: (palette.isDark
              ? const ColorScheme.dark()
              : const ColorScheme.light())
          .copyWith(
        primary: palette.accentPrimary,
        secondary: palette.accentSecondary,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        onPrimary: palette.accentPrimary.computeLuminance() > 0.25
            ? Colors.black
            : Colors.white,
      ),
      dividerColor:
          palette.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
            textStyle: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.1,
        )),
        bodyLarge: baseTextTheme.bodyLarge
            ?.copyWith(color: palette.textPrimary, height: 1.6),
        bodyMedium: baseTextTheme.bodyMedium
            ?.copyWith(color: palette.textPrimary, height: 1.6),
        bodySmall:
            baseTextTheme.bodySmall?.copyWith(color: palette.textSecondary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5),
        titleMedium: baseTextTheme.titleMedium
            ?.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
              color: palette.isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFE5E5EA),
              width: 1),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.textPrimary,
          foregroundColor: palette.isDark ? Colors.black : Colors.white,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accentPrimary,
        foregroundColor: palette.isDark ? Colors.black : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  // Fallback for parts of the app that haven't been updated to use Provider yet
  static ThemeData get darkTheme => getThemeData(ThemePalette.goldenDark);
}
