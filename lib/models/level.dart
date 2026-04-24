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
      levelNumber: json['levelNumber'] ?? 1,
      highScore: json['highScore'] ?? 0,
      stars: json['stars'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      gridRows: json['gridRows'] ?? 3,
      gridColumns: json['gridColumns'] ?? 3,
      moleStayDuration: json['moleStayDuration'] ?? 1000,
      bombChance: json['bombChance'] ?? 10,
      bombTimePenalty: json['bombTimePenalty'] ?? 3,
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
          moleStayDuration: 1070, // 1.07s - Very Easy
          bombChance: 5, // 5% bombs
          bombTimePenalty: 2,
        );
      case 2:
        return Level(
          levelNumber: 2,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1040, // 1.04s
          bombChance: 10, // 10% bombs
          bombTimePenalty: 2,
        );
      case 3:
        return Level(
          levelNumber: 3,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1010, // 1.01s
          bombChance: 15, // 15% bombs
          bombTimePenalty: 3,
        );
      case 4:
        return Level(
          levelNumber: 4,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 980, // 0.98s
          bombChance: 20, // 20% bombs
          bombTimePenalty: 3,
        );
      case 5:
        return Level(
          levelNumber: 5,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 950, // 0.95s
          bombChance: 25, // 25% bombs
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
          moleStayDuration: 920, // 0.92s - More holes, faster
          bombChance: 30, // 30% bombs
          bombTimePenalty: 4,
        );
      case 7:
        return Level(
          levelNumber: 7,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 890, // 0.89s
          bombChance: 35, // 35% bombs
          bombTimePenalty: 5,
        );
      case 8:
        return Level(
          levelNumber: 8,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 860, // 0.86s
          bombChance: 40, // 40% bombs
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
          moleStayDuration: 830, // 0.83s - Very challenging!
          bombChance: 45, // 45% bombs
          bombTimePenalty: 6,
        );
      case 10:
        return Level(
          levelNumber: 10,
          gridRows: 5,
          gridColumns: 5,
          moleStayDuration: 800, // 0.80s - EXTREME!
          bombChance: 50, // 50% bombs
          bombTimePenalty: 7,
        );

      default:
        return createLevel(1);
    }
  }
}
