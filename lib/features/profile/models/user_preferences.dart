import 'package:flutter/material.dart';

class UserPreferences {
  final String userId;
  final bool darkMode;
  final bool soundEffects;
  final bool hapticFeedback;
  final bool notifications;
  final int dailyGoal; // minutes
  final TimeOfDay? reminderTime;
  final String difficulty; // 'easy', 'medium', 'hard'
  final bool autoAdvanceLessons;
  final bool showKeyLabels;
  final String language; // 'en', 'es', 'fr', etc.

  const UserPreferences({
    required this.userId,
    this.darkMode = false,
    this.soundEffects = true,
    this.hapticFeedback = true,
    this.notifications = true,
    this.dailyGoal = 30,
    this.reminderTime,
    this.difficulty = 'medium',
    this.autoAdvanceLessons = true,
    this.showKeyLabels = true,
    this.language = 'en',
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'darkMode': darkMode,
      'soundEffects': soundEffects,
      'hapticFeedback': hapticFeedback,
      'notifications': notifications,
      'dailyGoal': dailyGoal,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'difficulty': difficulty,
      'autoAdvanceLessons': autoAdvanceLessons,
      'showKeyLabels': showKeyLabels,
      'language': language,
    };
  }

  // Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminderTime;
    if (json['reminderTime'] != null) {
      final parts = (json['reminderTime'] as String).split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return UserPreferences(
      userId: json['userId'] ?? '',
      darkMode: json['darkMode'] ?? false,
      soundEffects: json['soundEffects'] ?? true,
      hapticFeedback: json['hapticFeedback'] ?? true,
      notifications: json['notifications'] ?? true,
      dailyGoal: json['dailyGoal'] ?? 30,
      reminderTime: reminderTime,
      difficulty: json['difficulty'] ?? 'medium',
      autoAdvanceLessons: json['autoAdvanceLessons'] ?? true,
      showKeyLabels: json['showKeyLabels'] ?? true,
      language: json['language'] ?? 'en',
    );
  }

  // Copy with method
  UserPreferences copyWith({
    String? userId,
    bool? darkMode,
    bool? soundEffects,
    bool? hapticFeedback,
    bool? notifications,
    int? dailyGoal,
    TimeOfDay? reminderTime,
    bool clearReminderTime = false,
    String? difficulty,
    bool? autoAdvanceLessons,
    bool? showKeyLabels,
    String? language,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      darkMode: darkMode ?? this.darkMode,
      soundEffects: soundEffects ?? this.soundEffects,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      notifications: notifications ?? this.notifications,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderTime: clearReminderTime
          ? null
          : (reminderTime ?? this.reminderTime),
      difficulty: difficulty ?? this.difficulty,
      autoAdvanceLessons: autoAdvanceLessons ?? this.autoAdvanceLessons,
      showKeyLabels: showKeyLabels ?? this.showKeyLabels,
      language: language ?? this.language,
    );
  }

  // Default preferences
  factory UserPreferences.defaultPreferences(String userId) {
    return UserPreferences(userId: userId);
  }
}
