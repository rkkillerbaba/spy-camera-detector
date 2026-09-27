import 'package:flutter/material.dart';

class AppTheme {
  // Brand Security Dark Palette
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);

  // Security Neon Accents
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color neonGreenDim = Color(0x3300FF66);
  static const Color neonRed = Color(0xFFFF3366);
  static const Color neonRedDim = Color(0x33FF3366);
  static const Color neonYellow = Color(0xFFFFCC00);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFBF5AF2);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonCyan,
        error: neonRed,
        surface: surface,
        onSurface: textPrimary,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: neonGreen),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: neonGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
