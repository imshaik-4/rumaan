import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: const Color(0xFF37474F), // A deep blue-grey
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF37474F), // For app bar, primary buttons
      onPrimary: Colors.white,
      secondary: Color(0xFF546E7A), // For selected sidebar items
      onSecondary: Colors.white,
      surface: Colors.white, // For cards, backgrounds
      onSurface: Color(0xFF263238),
      error: Color(0xFFD32F2F), // Red for errors
      onError: Colors.white,
      outline: Color(0xFFE0E0E0), // For subtle borders
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF37474F),
      foregroundColor: Colors.white,
      elevation: 0, // Flat app bar
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: const Color(0xFF546E7A), width: 2), // Secondary color for focus
      ),
      labelStyle: TextStyle(color: Colors.grey[700]),
      hintStyle: TextStyle(color: Colors.grey[500]),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF37474F), // Primary color for buttons
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF37474F), // Primary color for text buttons
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    // Add other theme properties as needed
  );
}