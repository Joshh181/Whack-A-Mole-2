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
      // ═══════════════════════════════════════════════════════════
      // LEVELS 1-5: 3×3 GRID (9 holes) - Beginner
      // ═══════════════════════════════════════════════════════════
      case 1:
        return Level(
          levelNumber: 1,
          isUnlocked: true,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1100, // 1.0s - Very Easy
          bombChance: 0, // No bombs
          bombTimePenalty: 2,
        );
      case 2:
        return Level(
          levelNumber: 2,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1070, // 0.95s
          bombChance: 5, // 5% bombs
          bombTimePenalty: 2,
        );
      case 3:
        return Level(
          levelNumber: 3,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1040, // 0.9s
          bombChance: 10, // 10% bombs
          bombTimePenalty: 3,
        );
      case 4:
        return Level(
          levelNumber: 4,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1010, // 0.85s
          bombChance: 15, // 15% bombs
          bombTimePenalty: 3,
        );
      case 5:
        return Level(
          levelNumber: 5,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 980, // 0.8s
          bombChance: 20, // 20% bombs
          bombTimePenalty: 4,
        );

      // ═══════════════════════════════════════════════════════════
      // LEVELS 6-8: 4×4 GRID (16 holes) - Intermediate
      // ═══════════════════════════════════════════════════════════
      case 6:
        return Level(
          levelNumber: 6,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 950, // 0.75s - More holes, faster
          bombChance: 20, // 20% bombs
          bombTimePenalty: 4,
        );
      case 7:
        return Level(
          levelNumber: 7,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 920, // 0.7s
          bombChance: 25, // 25% bombs
          bombTimePenalty: 5,
        );
      case 8:
        return Level(
          levelNumber: 8,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 900, // 0.65s
          bombChance: 25, // 25% bombs
          bombTimePenalty: 5,
        );

      // ═══════════════════════════════════════════════════════════
      // LEVELS 9-10: 5×5 GRID (25 holes) - Expert
      // ═══════════════════════════════════════════════════════════
      case 9:
        return Level(
          levelNumber: 9,
          gridRows: 5,
          gridColumns: 5,
          moleStayDuration: 970, // 0.6s - Very challenging!
          bombChance: 30, // 30% bombs
          bombTimePenalty: 6,
        );
      case 10:
        return Level(
          levelNumber: 10,
          gridRows: 5,
          gridColumns: 5,
          moleStayDuration: 840, // 0.64s - EXTREME!
          bombChance: 35, // 35% bombs
          bombTimePenalty: 7,
        );

      default:
        return createLevel(1);
    }
  }
}
