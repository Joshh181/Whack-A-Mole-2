class Achievement {
  final String id;
  final String title;
  final String description;
  final int threshold;
  final String iconEmoji;
  int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.threshold,
    required this.iconEmoji,
    this.currentProgress = 0,
  });

  double get progressPercentage {
    return (currentProgress / threshold * 100).clamp(0, 100);
  }

  bool get isCompleted {
    return currentProgress >= threshold;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'threshold': threshold,
      'iconEmoji': iconEmoji,
      'currentPr`ogress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      threshold: json['threshold'],
      iconEmoji: json['iconEmoji'],
      currentProgress: json['currentProgress'] ?? 0,
    );
  }
}