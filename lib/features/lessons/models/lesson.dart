import 'lesson_content.dart';

class Lesson {
  final String id;
  final String title;
  final String category;
  final String description;
  final String difficulty; // beginner, intermediate, advanced
  final int estimatedDuration; // in minutes
  final int order;
  final bool isCompleted;
  final bool isLocked;
  final List<String> objectives;
  final List<String> notesToLearn;
  final LessonContent content;
  final DateTime createdAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.estimatedDuration,
    required this.order,
    this.isCompleted = false,
    this.isLocked = false,
    required this.objectives,
    required this.notesToLearn,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'order': order,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'objectives': objectives,
      'notesToLearn': notesToLearn,
      'content': content.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      estimatedDuration: json['estimatedDuration'] as int? ?? 10,
      order: json['order'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      objectives: List<String>.from(json['objectives'] as List? ?? []),
      notesToLearn: List<String>.from(json['notesToLearn'] as List? ?? []),
      content: LessonContent.fromJson(
        json['content'] as Map<String, dynamic>? ?? {},
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? difficulty,
    int? estimatedDuration,
    int? order,
    bool? isCompleted,
    bool? isLocked,
    List<String>? objectives,
    List<String>? notesToLearn,
    LessonContent? content,
    DateTime? createdAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      objectives: objectives ?? this.objectives,
      notesToLearn: notesToLearn ?? this.notesToLearn,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  String get difficultyLabel {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }

  String get statusLabel {
    if (isCompleted) return 'Completed';
    if (isLocked) return 'Locked';
    return 'Start';
  }
}
