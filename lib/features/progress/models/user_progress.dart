class UserProgress {
  final String userId;
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

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String? ?? '',
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      totalLessons: json['totalLessons'] as int? ?? 0,
      practiceAttempts: json['practiceAttempts'] as int? ?? 0,
      totalPracticeTime: json['totalPracticeTime'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
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
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
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
