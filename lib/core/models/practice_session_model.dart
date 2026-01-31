class PracticeSessionModel {
  final String id;
  final DateTime date;
  final double score;
  final double accuracy; // percentage 0-100
  final int duration; // in seconds
  final List<String> notesPlayed;

  PracticeSessionModel({
    required this.id,
    required this.date,
    required this.score,
    required this.accuracy,
    required this.duration,
    required this.notesPlayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'score': score,
      'accuracy': accuracy,
      'duration': duration,
      'notesPlayed': notesPlayed,
    };
  }

  factory PracticeSessionModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      duration: json['duration'] as int,
      notesPlayed: List<String>.from(json['notesPlayed'] as List),
    );
  }
}
