class PracticeSession {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalAttempts;
  final int correctAttempts;
  final int score;
  final double accuracy;
  final List<String> notesPlayed;
  final String difficulty;
  final int longestStreak;

  const PracticeSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.score = 0,
    this.accuracy = 0.0,
    this.notesPlayed = const [],
    required this.difficulty,
    this.longestStreak = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalAttempts': totalAttempts,
      'correctAttempts': correctAttempts,
      'score': score,
      'accuracy': accuracy,
      'notesPlayed': notesPlayed,
      'difficulty': difficulty,
      'longestStreak': longestStreak,
    };
  }

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      sessionId: json['sessionId'] as String? ?? '',
      startTime:
          DateTime.tryParse(json['startTime'] as String? ?? '') ??
          DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      correctAttempts: json['correctAttempts'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      notesPlayed: List<String>.from(json['notesPlayed'] as List? ?? []),
      difficulty: json['difficulty'] as String? ?? 'easy',
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  PracticeSession copyWith({
    String? sessionId,
    DateTime? startTime,
    DateTime? endTime,
    int? totalAttempts,
    int? correctAttempts,
    int? score,
    double? accuracy,
    List<String>? notesPlayed,
    String? difficulty,
    int? longestStreak,
  }) {
    return PracticeSession(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      score: score ?? this.score,
      accuracy: accuracy ?? this.accuracy,
      notesPlayed: notesPlayed ?? this.notesPlayed,
      difficulty: difficulty ?? this.difficulty,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  // Calculate duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get formattedDuration {
    final d = duration;
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  // Calculate stars based on accuracy
  int get stars {
    if (accuracy >= 90) return 3;
    if (accuracy >= 70) return 2;
    if (accuracy >= 50) return 1;
    return 0;
  }

  // Calculate XP earned
  int get xpEarned {
    return (score * 0.1).round() + (correctAttempts * 5) + (longestStreak * 2);
  }
}
