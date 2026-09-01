import 'package:flutter/material.dart';

class AppTheme {
  // ─── Warm Amber & Stone Palette (matching flutter_pdf_reader) ───
  static const Color kBgDark = Color(0xFF0C0A09); // Stone 950
  static const Color kSurfaceDark = Color(0xFF1C1917); // Stone 900
  static const Color kBorderDark = Color(0xFF292524); // Stone 800
  static const Color kTextPrimaryDark = Color(0xFFFAFAF9); // Stone 50
  static const Color kTextMutedDark = Color(0xFFA8A29E); // Stone 400

  static const Color kBgLight = Color(0xFFFAFAF9); // Stone 50
  static const Color kSurfaceLight = Color(0xFFFFFFFF);
  static const Color kBorderLight = Color(0xFFE7E5E4); // Stone 200
  static const Color kTextPrimaryLight = Color(0xFF1C1917); // Stone 900
  static const Color kTextMutedLight = Color(0xFF78716C); // Stone 500

  static const Color kAmber = Color(0xFFF59E0B); // Amber 500
  static const Color kAmberDark = Color(0xFFD97706); // Amber 600
  static const Color kAmberLight = Color(0xFFFBBF24); // Amber 400

  static const List<Color> categoryColors = [
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFF0D9488), // Teal
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
    Color(0xFF64748B), // Slate
    Color(0xFFD97706), // Amber Dark
  ];

  static const List<IconData> categoryIcons = [
    Icons.folder_rounded,
    Icons.person_rounded,
    Icons.work_rounded,
    Icons.shopping_cart_rounded,
    Icons.fitness_center_rounded,
    Icons.school_rounded,
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.code_rounded,
    Icons.flight_takeoff_rounded,
    Icons.book_rounded,
    Icons.star_rounded,
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: kBgLight,
      colorScheme: const ColorScheme.light(
        primary: kAmberDark,
        onPrimary: Colors.white,
        secondary: kAmber,
        onSecondary: Colors.white,
        surface: kSurfaceLight,
        onSurface: kTextPrimaryLight,
        outline: kBorderLight,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: kTextPrimaryLight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kTextPrimaryLight,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorderLight, width: 1),
        ),
        color: kSurfaceLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAmberDark, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kAmber,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kSurfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kAmber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBgDark,
      colorScheme: const ColorScheme.dark(
        primary: kAmber,
        onPrimary: Colors.white,
        secondary: kAmberDark,
        onSecondary: Colors.white,
        surface: kSurfaceDark,
        onSurface: kTextPrimaryDark,
        outline: kBorderDark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: kTextPrimaryDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kTextPrimaryDark,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorderDark, width: 1),
        ),
        color: kSurfaceDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kBorderDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAmber, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kAmber,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kSurfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kAmber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
