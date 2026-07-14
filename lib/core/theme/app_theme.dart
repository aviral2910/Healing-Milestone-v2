import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Golden & Black Palette with Titanium Accents
  static const Color background = Color(0xFF000000); // True OLED Black
  static const Color surface = Color(0xFF0F0F0F); // Deep Charcoal for depth
  
  static const Color textPrimary = Color(0xFFF5F5F7); // Frost White for primary reading
  static const Color textSecondary = Color(0xFFA1A1A6); // Titanium Silver for subtitles
  
  static const Color accentPrimary = Color(0xFFD4AF37); // Premium Gold
  static const Color accentSecondary = Color(0xFF878681); // Natural Titanium

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accentPrimary,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
            color: textPrimary, 
            fontSize: 18, 
            fontWeight: FontWeight.w800, 
            letterSpacing: -0.5
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          textStyle: const TextStyle(
            color: textPrimary, 
            fontWeight: FontWeight.w800, 
            letterSpacing: -1.0,
            height: 1.1,
          )
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary, height: 1.6),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textPrimary, height: 1.6),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSecondary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, // Flat design with massive spacing
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: Color(0xFF2A2A2A), width: 1), // Titanium subtle border
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
          backgroundColor: textPrimary, // White button
          foregroundColor: Colors.black, // Black text on white button
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
