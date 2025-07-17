// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFD97706);
  static const Color secondaryColor = Color(0xFFFEF3C7);
  static const Color backgroundColor = Color(0xFFFFFBEB);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(0xFFD97706, {
      50: Color(0xFFFFFBEB),
      100: Color(0xFFFEF3C7),
      200: Color(0xFFFDE68A),
      300: Color(0xFFFCD34D),
      400: Color(0xFFFBBF24),
      500: Color(0xFFF59E0B),
      600: Color(0xFFD97706),
      700: Color(0xFFB45309),
      800: Color(0xFF92400E),
      900: Color(0xFF78350F),
    }),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}