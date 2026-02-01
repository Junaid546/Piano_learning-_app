import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/providers/profile_provider.dart';

/// Theme mode provider - watches user preferences and returns appropriate ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final preferencesAsync = ref.watch(userPreferencesProvider);

  return preferencesAsync.when(
    data: (preferences) =>
        preferences.darkMode ? ThemeMode.dark : ThemeMode.light,
    loading: () => ThemeMode.system, // Use system theme while loading
    error: (_, __) => ThemeMode.system, // Fallback to system on error
  );
});

/// Simple bool provider for dark mode status
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
