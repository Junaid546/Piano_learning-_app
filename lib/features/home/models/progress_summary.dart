class ProgressSummary {
  final int lessonsCompletedCount;
  final int totalLessons;
  final int practiceSessionsCount;
  final int totalPracticeTimeMinutes;
  final int currentStreak;
  final int currentLevel;
  final List<String> recentAchievements;

  const ProgressSummary({
    required this.lessonsCompletedCount,
    required this.totalLessons,
    required this.practiceSessionsCount,
    required this.totalPracticeTimeMinutes,
    required this.currentStreak,
    required this.currentLevel,
    required this.recentAchievements,
  });

  factory ProgressSummary.initial() {
    return const ProgressSummary(
      lessonsCompletedCount: 0,
      totalLessons: 20, // Example total
      practiceSessionsCount: 0,
      totalPracticeTimeMinutes: 0,
      currentStreak: 0,
      currentLevel: 1,
      recentAchievements: [],
    );
  }

  // Helper to calculate percentage
  double get totalProgress {
    if (totalLessons == 0) return 0.0;
    return (lessonsCompletedCount / totalLessons).clamp(0.0, 1.0);
  }
}
