import 'package:flutter/material.dart';
// import 'app_colors.dart'; // Unused

class AppTextStyles {
  AppTextStyles._();

  // Display: Poppins (headings, 24-32px, bold)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // Title: Poppins (subtitles, 18-22px, semi-bold)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Body: Inter (content, 14-16px, regular)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Caption: Inter (small text, 12px, regular)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Helper methods to get styles with specific colors
  static TextStyle getDisplayLarge(Color color) =>
      displayLarge.copyWith(color: color);
  static TextStyle getDisplayMedium(Color color) =>
      displayMedium.copyWith(color: color);
  static TextStyle getDisplaySmall(Color color) =>
      displaySmall.copyWith(color: color);

  static TextStyle getTitleLarge(Color color) =>
      titleLarge.copyWith(color: color);
  static TextStyle getTitleMedium(Color color) =>
      titleMedium.copyWith(color: color);
  static TextStyle getTitleSmall(Color color) =>
      titleSmall.copyWith(color: color);

  static TextStyle getBodyLarge(Color color) =>
      bodyLarge.copyWith(color: color);
  static TextStyle getBodyMedium(Color color) =>
      bodyMedium.copyWith(color: color);
  static TextStyle getLabelSmall(Color color) =>
      labelSmall.copyWith(color: color);
}
