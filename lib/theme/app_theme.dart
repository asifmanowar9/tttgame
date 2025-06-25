import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF8A56FF);
  static const Color gradientStart = Color(0xFFCB5860);
  static const Color gradientEnd = Color(0xFFC24BC4);
  
  // Game colors
  static const Color xColor = Color(0xFF8A56FF);
  static const Color oColor = Color(0xFFFFFFFF);
  static const Color boardColor = Color(0xFF8A56FF);
  
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      fontFamily: GoogleFonts.righteous().fontFamily,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 5,
          textStyle: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.righteous(
          fontSize: 32, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
        titleLarge: GoogleFonts.righteous(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
        bodyLarge: GoogleFonts.righteous(
          fontSize: 18, 
          color: Colors.white
        ),
      ),
    );
  }
}
