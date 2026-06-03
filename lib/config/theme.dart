import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FRELIMO brand palette (per the party's brand guidelines).
///
/// PRIMARY red, SECONDARY gold, ACCENT green — these mirror the four-stripe
/// flag motif. The dark surface is a deep green-black used for card backgrounds
/// so that the gold/red foreground reads cleanly. Never use a raw brand colour
/// for scaffold/appBar — always go through the surface tokens (`lightBg`,
/// `darkBg`) so the toggle works and the UI stays readable in both modes.
class AppColors {
  // Brand
  static const Color primaryRed   = Color(0xFFCE1126); // 206,17,38 — FRELIMO red
  static const Color brandGold    = Color(0xFFFCD116); // 252,209,22 — secondary
  static const Color brandGreen   = Color(0xFF009E49); // 0,158,73 — accent
  static const Color brandBlack   = Color(0xFF000000); // flag stripe
  static const Color darkSurface  = Color(0xFF0F1A14); // deep green-black

  // Surface tokens — use these for scaffold/appBar/card.
  static const Color lightBg     = Color(0xFFFAFAFA);
  static const Color lightCard   = Color(0xFFFFFFFF);
  static const Color darkBg      = Color(0xFF0A0A0A);
  static const Color darkCard    = Color(0xFF1A1A1A);
  static const Color darkAppBar  = Color(0xFF0F0F0F);
  static const Color darkBorder  = Color(0xFF262626);

  // Semantic
  static const Color success           = Color(0xFF10B981);
  static const Color warning           = Color(0xFFF59E0B);
  static const Color error             = primaryRed;
  static const Color textPrimaryDark   = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B3B8);

  /// The four-stripe flag gradient used on the digital card + login hero.
  static const List<Color> flagStripes = [
    brandGreen,
    brandGold,
    primaryRed,
    brandBlack,
  ];
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryRed,
          secondary: AppColors.brandGold,
          tertiary: AppColors.brandGreen,
          surface: Colors.white,
          onSurface: Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: AppColors.lightBg,
        canvasColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryRed,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF3F4F6),
          selectedColor: AppColors.primaryRed.withValues(alpha: 0.15),
          labelStyle: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          showCheckmark: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryRed,
          secondary: AppColors.brandGold,
          tertiary: AppColors.brandGreen,
          surface: AppColors.darkCard,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: AppColors.darkBg,
        canvasColor: AppColors.darkCard,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkAppBar,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkBorder,
          selectedColor: AppColors.primaryRed.withValues(alpha: 0.25),
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          showCheckmark: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkBorder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      );
}
