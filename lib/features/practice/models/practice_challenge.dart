class PracticeChallenge {
  final String id;
  final String challengeType; // "play_note", "play_sequence"
  final String targetNote;
  final List<String>? targetSequence;
  final String difficulty; // easy, medium, hard
  final int? timeLimit; // in seconds

  const PracticeChallenge({
    required this.id,
    required this.challengeType,
    required this.targetNote,
    this.targetSequence,
    required this.difficulty,
    this.timeLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeType': challengeType,
      'targetNote': targetNote,
      'targetSequence': targetSequence,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
    };
  }

  factory PracticeChallenge.fromJson(Map<String, dynamic> json) {
    return PracticeChallenge(
      id: json['id'] as String? ?? '',
      challengeType: json['challengeType'] as String? ?? 'play_note',
      targetNote: json['targetNote'] as String? ?? 'C4',
      targetSequence: json['targetSequence'] != null
          ? List<String>.from(json['targetSequence'] as List)
          : null,
      difficulty: json['difficulty'] as String? ?? 'easy',
      timeLimit: json['timeLimit'] as int?,
    );
  }

  bool get isSequence => challengeType == 'play_sequence';

  // Generate random challenges
  static PracticeChallenge generateRandom(String difficulty) {
    final easyNotes = ['C4', 'D4', 'E4', 'F4', 'G4'];
    final mediumNotes = ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'];
    final hardNotes = [
      'C4',
      'Db4',
      'D4',
      'Eb4',
      'E4',
      'F4',
      'Gb4',
      'G4',
      'Ab4',
      'A4',
      'Bb4',
      'B4',
    ];

    List<String> notes;
    int? timeLimit;

    switch (difficulty) {
      case 'easy':
        notes = easyNotes;
        timeLimit = null;
        break;
      case 'medium':
        notes = mediumNotes;
        timeLimit = 10;
        break;
      case 'hard':
        notes = hardNotes;
        timeLimit = 5;
        break;
      default:
        notes = easyNotes;
    }

    // Shuffle and pick random note
    notes.shuffle();
    final targetNote = notes.first;

    return PracticeChallenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      challengeType: 'play_note',
      targetNote: targetNote,
      difficulty: difficulty,
      timeLimit: timeLimit,
    );
  }
}
