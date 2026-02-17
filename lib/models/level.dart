class Level {
  final int levelNumber;
  int highScore;
  int stars;
  bool isUnlocked;
  
  final int gridRows;
  final int gridColumns;
  final int moleStayDuration;
  final int bombChance;
  final int bombTimePenalty;

  Level({
    required this.levelNumber,
    this.highScore = 0,
    this.stars = 0,
    this.isUnlocked = false,
    required this.gridRows,
    required this.gridColumns,
    required this.moleStayDuration,
    required this.bombChance,
    required this.bombTimePenalty,
  });

  int get totalHoles => gridRows * gridColumns;

  int calculateStars(int score) {
    if (score >= 100) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }

  void updateScore(int newScore) {
    if (newScore > highScore) {
      highScore = newScore;
      stars = calculateStars(newScore);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'highScore': highScore,
      'stars': stars,
      'isUnlocked': isUnlocked,
      'gridRows': gridRows,
      'gridColumns': gridColumns,
      'moleStayDuration': moleStayDuration,
      'bombChance': bombChance,
      'bombTimePenalty': bombTimePenalty,
    };
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelNumber: json['levelNumber'],
      highScore: json['highScore'] ?? 0,
      stars: json['stars'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      gridRows: json['gridRows'],
      gridColumns: json['gridColumns'],
      moleStayDuration: json['moleStayDuration'],
      bombChance: json['bombChance'],
      bombTimePenalty: json['bombTimePenalty'],
    );
  }

  static Level createLevel(int number) {
    switch (number) {
      case 1:
        return Level(
          levelNumber: 1,
          isUnlocked: true,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1000,  // 1 seconds - MUCH LONGER!
          bombChance: 10,  // ABSOLUTELY NO BOMBS IN LEVEL 1!
          bombTimePenalty: 2,
        );
      case 2:
        return Level(
          levelNumber: 2,
          gridRows: 4,
          gridColumns: 3,
          moleStayDuration: 900,  // 0.9 seconds
          bombChance: 15,  // Only 5% bombs (very rare)
          bombTimePenalty: 3,
        );
      case 3:
        return Level(
          levelNumber: 3,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 850,  // 0.85 seconds
          bombChance: 20,  // 10% bombs
          bombTimePenalty: 5,
        );
      case 4:
        return Level(
          levelNumber: 4,
          gridRows: 5,
          gridColumns: 4,
          moleStayDuration: 800,  // 0.8 seconds
          bombChance: 30,  // 15% bombs
          bombTimePenalty: 7,
        );
      case 5:
        return Level(
          levelNumber: 5,
          gridRows: 5,
          gridColumns: 5,
          moleStayDuration: 700,  // 0.7 seconds - hardest
          bombChance: 40,  // 20% bombs
          bombTimePenalty: 9,
        );
      default:
        return createLevel(1);
    }
  }
}