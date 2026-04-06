// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Primary palette — earthy Zanzibar greens
  static const Color primary       = Color(0xFF2D6A4F);
  static const Color primaryLight  = Color(0xFF52B788);
  static const Color primaryDark   = Color(0xFF1B4332);
  static const Color accent        = Color(0xFFD9A843);   // warm gold
  static const Color accentLight   = Color(0xFFF4D03F);
  static const Color background    = Color(0xFFF8F5EF);   // warm off-white
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color error         = Color(0xFFD62828);
  static const Color warning       = Color(0xFFE07B23);
  static const Color textPrimary   = Color(0xFF1A2E1A);
  static const Color textSecondary = Color(0xFF5A7A5A);
  static const Color divider       = Color(0xFFDDE8D4);

  // Severity colours
  static const Color severityLow    = Color(0xFF52B788);
  static const Color severityMedium = Color(0xFFE07B23);
  static const Color severityHigh   = Color(0xFFD62828);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      background: background,
      surface: surface,
      error: error,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shadowColor: primary.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryLight.withOpacity(0.15),
      labelStyle: const TextStyle(color: primaryDark, fontWeight: FontWeight.w500),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      default:              return severityLow;
    }
  }

  static IconData severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      default:              return Icons.check_circle_rounded;
    }
  }
}

// Needed for severityColor helper
