import 'package:flutter/material.dart';

class AppTheme {
  // --- GOTHIC CYBERPUNK PALETTE ---
  // A dark, high-contrast theme with deep reds and stark whites.
  
  // Primary color is a visceral, blood-like red.
  static const Color primaryColor = Color(0xFFE60023); // Crimson Red
  static const Color secondaryColor = Color(0xFFF0F0F0); // Stark Off-White
  
  // Status colors that fit the aggressive theme.
  static const Color errorColor = Color(0xFFE60023);   // Same as primary for consistency
  static const Color successColor = Color(0xFF00A86B); // Deep Jade Green

  // --- Dark Theme: "Cathedral of Code" ---
  // Using a near-black palette for maximum contrast.
  static const Color backgroundDark = Color(0xFF0A0A0A); // Near Black
  static const Color surfaceDark = Color(0xFF141414);   // Very Dark Gray
  static const Color cardDark = Color(0xFF1A1A1A);       // Dark Gray

  // --- Light Theme: "Sterile Lab" (High-contrast light mode) ---
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceLight = Color(0xFFF5F5F5);    // Off-White
  static const Color cardLight = Color(0xFFFFFFFF);

  // --- Universal Text & Border Colors ---
  static const Color textPrimaryDark = Color(0xFFFFFFFF);   // Pure White for max contrast
  static const Color textSecondaryDark = Color(0xFFA9A9A9); // Light Gray
  static const Color textMutedDark = Color(0xFF686868);     // Medium Gray

  static const Color textPrimaryLight = Color(0xFF0A0A0A); // Near Black on white
  
  static const Color borderDark = Color(0xFF333333);  // Dark Gray for subtle borders
  static const Color borderLight = Color(0xFFE0E0E0); // Light Gray

  // --- LEGACY COLORS (for compatibility with existing code) ---
  // These are kept to prevent breaking changes in other files.
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textMuted = textMutedDark;
  static const Color borderColor = borderDark;


  // --- THEME DEFINITIONS ---

  /// The light theme, a stark, high-contrast "sterile" look.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceLight,
        error: errorColor,
        onSurface: textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimaryDark, // White text on red button
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: TextStyle(color: textPrimaryLight.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight, size: 24),
    );
  }

  /// The dark theme, for a high-contrast, aggressive gothic-tech aesthetic.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceDark,
        error: errorColor,
        onSurface: textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: borderDark, width: 1),
        ),
      ),
       elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimaryDark, // White text on red button
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryDark,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMutedDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      iconTheme: const IconThemeData(color: textSecondaryDark, size: 24),
    );
  }
}

