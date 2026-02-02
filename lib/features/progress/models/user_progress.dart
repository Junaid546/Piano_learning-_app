class UserProgress {
  final String userId;
  final List<String> completedLessonIds; // Per-user lesson completion
  final int lessonsCompleted;
  final int totalLessons;
  final int practiceAttempts;
  final int totalPracticeTime; // minutes
  final int currentStreak;
  final int longestStreak;
  final double accuracy;
  final int level;
  final int xp;
  final List<String> achievementsUnlocked;
  final DateTime? lastPracticeDate;
  final Map<String, int> practiceDates; // date -> minutes

  const UserProgress({
    required this.userId,
    this.completedLessonIds = const [],
    this.lessonsCompleted = 0,
    this.totalLessons = 0,
    this.practiceAttempts = 0,
    this.totalPracticeTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.accuracy = 0.0,
    this.level = 1,
    this.xp = 0,
    this.achievementsUnlocked = const [],
    this.lastPracticeDate,
    this.practiceDates = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'completedLessonIds': completedLessonIds,
      'lessonsCompleted': lessonsCompleted,
      'totalLessons': totalLessons,
      'practiceAttempts': practiceAttempts,
      'totalPracticeTime': totalPracticeTime,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'accuracy': accuracy,
      'level': level,
      'xp': xp,
      'achievementsUnlocked': achievementsUnlocked,
      'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      'practiceDates': practiceDates,
    };
  }

  /// Safe integer conversion that handles corrupted data (e.g., List<dynamic>)
  static int _safeToInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    // Handle corrupted data (e.g., List<dynamic>)
    return defaultValue;
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String? ?? '',
      completedLessonIds:
          List<String>.from(json['completedLessonIds'] as List? ?? []),
      lessonsCompleted: _safeToInt(json['lessonsCompleted'], 0),
      totalLessons: _safeToInt(json['totalLessons'], 0),
      practiceAttempts: _safeToInt(json['practiceAttempts'], 0),
      totalPracticeTime: _safeToInt(json['totalPracticeTime'], 0),
      currentStreak: _safeToInt(json['currentStreak'], 0),
      longestStreak: _safeToInt(json['longestStreak'], 0),
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      level: _safeToInt(json['level'], 1),
      xp: _safeToInt(json['xp'], 0),
      achievementsUnlocked: List<String>.from(
        json['achievementsUnlocked'] as List? ?? [],
      ),
      lastPracticeDate: json['lastPracticeDate'] != null
          ? DateTime.tryParse(json['lastPracticeDate'] as String)
          : null,
      practiceDates: Map<String, int>.from(json['practiceDates'] as Map? ?? {}),
    );
  }

  UserProgress copyWith({
    String? userId,
    List<String>? completedLessonIds,
    int? lessonsCompleted,
    int? totalLessons,
    int? practiceAttempts,
    int? totalPracticeTime,
    int? currentStreak,
    int? longestStreak,
    double? accuracy,
    int? level,
    int? xp,
    List<String>? achievementsUnlocked,
    DateTime? lastPracticeDate,
    Map<String, int>? practiceDates,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lessonsCompleted: completedLessonIds != null
          ? completedLessonIds.length
          : (lessonsCompleted ?? this.lessonsCompleted),
      totalLessons: totalLessons ?? this.totalLessons,
      practiceAttempts: practiceAttempts ?? this.practiceAttempts,
      totalPracticeTime: totalPracticeTime ?? this.totalPracticeTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      accuracy: accuracy ?? this.accuracy,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      practiceDates: practiceDates ?? this.practiceDates,
    );
  }

  // Helper getters
  double get completionPercentage {
    if (totalLessons == 0) return 0.0;
    return (lessonsCompleted / totalLessons * 100);
  }

  int get totalPracticeHours => (totalPracticeTime / 60).floor();

  String get formattedPracticeTime {
    final hours = totalPracticeHours;
    final minutes = totalPracticeTime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int get xpToNextLevel {
    return level * 100;
  }

  double get levelProgress {
    return (xp % xpToNextLevel) / xpToNextLevel;
  }
}
