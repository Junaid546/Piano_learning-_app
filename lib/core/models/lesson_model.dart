enum LessonDifficulty { beginner, intermediate, advanced }

class LessonModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final LessonDifficulty difficulty;
  final int estimatedDuration; // in minutes
  final int order;
  final Map<String, dynamic> content;
  final List<String> notesToPlay;

  LessonModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.estimatedDuration,
    required this.order,
    required this.content,
    required this.notesToPlay,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'difficulty': difficulty.name,
      'estimatedDuration': estimatedDuration,
      'order': order,
      'content': content,
      'notesToPlay': notesToPlay,
    };
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      difficulty: LessonDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => LessonDifficulty.beginner,
      ),
      estimatedDuration: json['estimatedDuration'] as int,
      order: json['order'] as int,
      content: json['content'] as Map<String, dynamic>,
      notesToPlay: List<String>.from(json['notesToPlay'] as List),
    );
  }
}
