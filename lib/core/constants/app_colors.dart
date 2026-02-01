import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // PRIMARY COLORS - Brand Identity
  static const Color primaryPurple = Color(0xFF6B4CE6); // Deep vibrant purple
  static const Color primaryLight = Color(0xFF9D84F5); // Lighter variation
  static const Color primaryDark = Color(0xFF4A2BC2); // Darker depth

  static const Color secondaryPink = Color(0xFFFF6B9D); // Playful accent
  static const Color accentGold = Color(0xFFFFD700); // Achievement/Premium

  // GRADIENTS
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6B4CE6), Color(0xFF9D84F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF4F6F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    colors: [Color(0xFF1F2232), Color(0xFF151725)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // BACKGROUND COLORS - Light Mode (Warm & Clean)
  static const Color backgroundLight = Color(
    0xFFF4F6F9,
  ); // Soft cool grey-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F2F5);
  static const Color cardLight = Color(0xFFFFFFFF);

  // BACKGROUND COLORS - Dark Mode (Deep & Rich)
  static const Color backgroundDark = Color(0xFF0F111A); // Deep midnight
  static const Color surfaceDark = Color(0xFF1A1C29);
  static const Color surfaceVariantDark = Color(0xFF25283A);
  static const Color cardDark = Color(0xFF1E2030);

  // FUNCTIONAL COLORS (Soft Pastels for modern look)
  static const Color successGreen = Color(0xFF2DCA73);
  static const Color successSoft = Color(0xFFE3F9EC);

  static const Color errorRed = Color(0xFFFF4B4B);
  static const Color errorSoft = Color(0xFFFFEDEC);
  static const Color error = errorRed;

  static const Color warningOrange = Color(0xFFFFB300);
  static const Color warningSoft = Color(0xFFFFF8E1);

  static const Color infoBlue = Color(0xFF42A5F5);
  static const Color infoSoft = Color(0xFFE3F2FD);

  // TEXT COLORS
  static const Color textPrimaryLight = Color(0xFF1A1C24);
  static const Color textSecondaryLight = Color(0xFF6E7191);
  static const Color textTertiaryLight = Color(0xFFA0A3BD);

  static const Color textPrimaryDark = Color(0xFFF7F7FC);
  static const Color textSecondaryDark = Color(0xFFA0A3BD);
  static const Color textTertiaryDark = Color(0xFF6E7191);

  static const Color textTertiary = Color(0xFF999999); // Legacy fallback

  // PIANO KEY COLORS
  static const Color whiteKey = Color(0xFFFFFFFF);
  static const Color blackKey = Color(0xFF141416);
  static const Color keyPressed = Color.fromARGB(150, 107, 76, 230);
  static const Color keyCorrect = Color(0xFF2DCA73);
  static const Color keyIncorrect = Color(0xFFFF4B4B);

  // GLASSMORPHISM
  static Color glassLight = Colors.white.withOpacity(0.7);
  static Color glassDark = const Color(0xFF1A1C29).withOpacity(0.6);
  static const double glassBlur = 10.0;
}
