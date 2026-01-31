class LessonContent {
  final String theoryText;
  final List<String> demoNotes;
  final List<String> practiceNotes;
  final List<String> tips;
  final String? illustrationUrl;

  const LessonContent({
    required this.theoryText,
    required this.demoNotes,
    required this.practiceNotes,
    required this.tips,
    this.illustrationUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'theoryText': theoryText,
      'demoNotes': demoNotes,
      'practiceNotes': practiceNotes,
      'tips': tips,
      'illustrationUrl': illustrationUrl,
    };
  }

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      theoryText: json['theoryText'] as String? ?? '',
      demoNotes: List<String>.from(json['demoNotes'] as List? ?? []),
      practiceNotes: List<String>.from(json['practiceNotes'] as List? ?? []),
      tips: List<String>.from(json['tips'] as List? ?? []),
      illustrationUrl: json['illustrationUrl'] as String?,
    );
  }

  LessonContent copyWith({
    String? theoryText,
    List<String>? demoNotes,
    List<String>? practiceNotes,
    List<String>? tips,
    String? illustrationUrl,
    bool clearIllustration = false,
  }) {
    return LessonContent(
      theoryText: theoryText ?? this.theoryText,
      demoNotes: demoNotes ?? this.demoNotes,
      practiceNotes: practiceNotes ?? this.practiceNotes,
      tips: tips ?? this.tips,
      illustrationUrl: clearIllustration
          ? null
          : (illustrationUrl ?? this.illustrationUrl),
    );
  }
}
