import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryPink,
        tertiary: AppColors.accentGold,
        surface: AppColors.surfaceDark,
        error: AppColors.errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.black,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.cardDark,

      textTheme: TextTheme(
        displayLarge: AppTextStyles.getDisplayLarge(AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.getDisplayMedium(
          AppColors.textPrimaryDark,
        ),
        displaySmall: AppTextStyles.getDisplaySmall(AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.getDisplaySmall(AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.getTitleLarge(AppColors.textPrimaryDark),
        headlineSmall: AppTextStyles.getTitleMedium(AppColors.textPrimaryDark),
        titleLarge: AppTextStyles.getTitleMedium(AppColors.textPrimaryDark),
        titleMedium: AppTextStyles.getTitleSmall(AppColors.textPrimaryDark),
        titleSmall: AppTextStyles.getBodyLarge(
          AppColors.textPrimaryDark,
        ).copyWith(fontWeight: FontWeight.bold),
        bodyLarge: AppTextStyles.getBodyLarge(AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.getBodyMedium(AppColors.textSecondaryDark),
        bodySmall: AppTextStyles.getLabelSmall(AppColors.textSecondaryDark),
        labelLarge: AppTextStyles.getBodyMedium(
          AppColors.textPrimaryDark,
        ).copyWith(fontWeight: FontWeight.bold),
        labelMedium: AppTextStyles.getLabelSmall(AppColors.textSecondaryDark),
        labelSmall: AppTextStyles.getLabelSmall(AppColors.textSecondaryDark),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}
