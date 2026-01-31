class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName; // Material icon name
  final int requirement;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String rarity; // bronze, silver, gold, platinum
  final String category; // lessons, practice, streak, accuracy, notes

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requirement,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedDate,
    required this.rarity,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'requirement': requirement,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'rarity': rarity,
      'category': category,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'emoji_events',
      requirement: json['requirement'] as int? ?? 0,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.tryParse(json['unlockedDate'] as String)
          : null,
      rarity: json['rarity'] as String? ?? 'bronze',
      category: json['category'] as String? ?? 'general',
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? requirement,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedDate,
    String? rarity,
    String? category,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      requirement: requirement ?? this.requirement,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
    );
  }

  double get progressPercentage {
    if (requirement == 0) return 0.0;
    return (currentProgress / requirement * 100).clamp(0.0, 100.0);
  }

  bool get isInProgress => currentProgress > 0 && !isUnlocked;
}
