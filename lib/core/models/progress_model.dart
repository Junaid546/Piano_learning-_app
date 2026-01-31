class ProgressModel {
  final List<String> lessonsCompleted;
  final int practiceAttempts;
  final int totalPracticeTime; // in minutes
  final int currentStreak;
  final DateTime lastPracticeDate;
  final List<String> achievements;

  ProgressModel({
    required this.lessonsCompleted,
    required this.practiceAttempts,
    required this.totalPracticeTime,
    required this.currentStreak,
    required this.lastPracticeDate,
    required this.achievements,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonsCompleted': lessonsCompleted,
      'practiceAttempts': practiceAttempts,
      'totalPracticeTime': totalPracticeTime,
      'currentStreak': currentStreak,
      'lastPracticeDate': lastPracticeDate.toIso8601String(),
      'achievements': achievements,
    };
  }

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      lessonsCompleted: List<String>.from(
        json['lessonsCompleted'] as List? ?? [],
      ),
      practiceAttempts: json['practiceAttempts'] as int? ?? 0,
      totalPracticeTime: json['totalPracticeTime'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastPracticeDate:
          DateTime.tryParse(json['lastPracticeDate'] as String? ?? '') ??
          DateTime.now(),
      achievements: List<String>.from(json['achievements'] as List? ?? []),
    );
  }

  ProgressModel copyWith({
    List<String>? lessonsCompleted,
    int? practiceAttempts,
    int? totalPracticeTime,
    int? currentStreak,
    DateTime? lastPracticeDate,
    List<String>? achievements,
  }) {
    return ProgressModel(
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      practiceAttempts: practiceAttempts ?? this.practiceAttempts,
      totalPracticeTime: totalPracticeTime ?? this.totalPracticeTime,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      achievements: achievements ?? this.achievements,
    );
  }
}
