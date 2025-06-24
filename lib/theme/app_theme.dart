import 'package:flutter/material.dart';

class AppTheme {
  // Main purple color from the design
  static const Color primaryColor = Color(0xFF8A56FF);

  // Gradient colors from the design
  static const Color gradientStart = Color(0xFFCB5860);
  static const Color gradientEnd = Color(0xFFC24BC4);

  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      fontFamily: 'Roboto',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
