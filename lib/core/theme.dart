import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AxiomTheme {
  // Brand Colors
  static const Color background = Color(0xFF0D1117);
  static const Color primaryCyan = Color(0xFF00F5D4);
  static const Color primaryPurple = Color(0xFF7928CA);
  static const Color accentGold = Color(0xFFFFBE0B);
  static const Color textWhite = Color(0xFFF8F9FA);
  static const Color errorRed = Color(0xFFFF5252);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: primaryCyan,
        surface: background,
        error: errorRed,
        onPrimary: textWhite,
        onSecondary: background,
      ),
      textTheme: GoogleFonts.pressStart2pTextTheme().copyWith(
        displayLarge: GoogleFonts.vt323(fontSize: 48, color: textWhite),
        displayMedium: GoogleFonts.vt323(fontSize: 36, color: textWhite),
        bodyLarge: GoogleFonts.robotoMono(fontSize: 18, color: textWhite),
        bodyMedium: GoogleFonts.robotoMono(fontSize: 14, color: textWhite),
        labelLarge: GoogleFonts.pressStart2p(fontSize: 12, color: background), // For Buttons
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.pressStart2p(fontSize: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF161B22),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: primaryPurple, width: 2),
        ),
      ),
    );
  }
}
