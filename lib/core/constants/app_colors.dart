import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // PRIMARY COLORS
  static const Color primaryPurple = Color(0xFF6B4CE6);
  static const Color secondaryPink = Color(0xFFFF6B9D);
  static const Color accentGold = Color(0xFFFFD700);

  // BACKGROUND COLORS - Light Mode
  static const Color backgroundLight = Color(0xFFFAF9F6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // BACKGROUND COLORS - Dark Mode
  static const Color backgroundDark = Color(0xFF1A1B2E);
  static const Color surfaceDark = Color(0xFF252638);
  static const Color cardDark = Color(0xFF2D2F48);

  // FUNCTIONAL COLORS
  static const Color successGreen = Color(0xFF4ECDC4);
  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color warningOrange = Color(0xFFFFA726);
  static const Color infoBlue = Color(0xFF42A5F5);

  // TEXT COLORS
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static const Color textTertiary = Color(0xFF999999);

  // PIANO KEY COLORS
  static const Color whiteKey = Color(0xFFFFFFFF);
  static const Color blackKey = Color(0xFF1A1A1A);
  static const Color keyPressed = Color.fromARGB(
    150,
    107,
    76,
    230,
  ); // primaryPurple with opacity
  static const Color keyCorrect = Color(0xFF4ECDC4);
  static const Color keyIncorrect = Color(0xFFFF6B6B);
}
