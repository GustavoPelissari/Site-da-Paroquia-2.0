import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color vinhoParoquial = Color(0xFF80152B);
  static const Color fundo = Color(0xFFF8F6F4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color douradoSuave = Color(0xFFD3B585);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: fundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: vinhoParoquial,
      primary: vinhoParoquial,
      secondary: douradoSuave,
      surface: card,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: vinhoParoquial,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: vinhoParoquial,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: vinhoParoquial,
      ),
      titleMedium: GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: vinhoParoquial,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 1.35,
        color: const Color(0xFF1F1D1C),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.35,
        color: const Color(0xFF2B2827),
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFF5D5856),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: vinhoParoquial,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide.none,
      backgroundColor: const Color(0xFFF0E6E8),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        color: vinhoParoquial,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: vinhoParoquial,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),
    cardTheme: CardThemeData(
      color: card,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
