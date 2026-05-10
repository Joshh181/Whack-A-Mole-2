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
  final int maxActiveMoles;  // Max moles on screen at once
  final int spawnInterval;   // ms between spawn attempts

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
    this.maxActiveMoles = 1,
    this.spawnInterval = 1300,
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
      'maxActiveMoles': maxActiveMoles,
      'spawnInterval': spawnInterval,
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
      maxActiveMoles: json['maxActiveMoles'] ?? 1,
      spawnInterval: json['spawnInterval'] ?? 1300,
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
          moleStayDuration: 1200,
          bombChance: 5,
          bombTimePenalty: 2,
          maxActiveMoles: 1,
          spawnInterval: 1300,
        );
      case 2:
        return Level(
          levelNumber: 2,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1150,
          bombChance: 10,
          bombTimePenalty: 2,
          maxActiveMoles: 1,
          spawnInterval: 1250,
        );
      case 3:
        return Level(
          levelNumber: 3,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1100,
          bombChance: 15,
          bombTimePenalty: 3,
          maxActiveMoles: 1,
          spawnInterval: 1200,
        );
      case 4:
        return Level(
          levelNumber: 4,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1050,
          bombChance: 20,
          bombTimePenalty: 3,
          maxActiveMoles: 1,
          spawnInterval: 1150,
        );
      case 5:
        return Level(
          levelNumber: 5,
          gridRows: 3,
          gridColumns: 3,
          moleStayDuration: 1000,
          bombChance: 25,
          bombTimePenalty: 4,
          maxActiveMoles: 2,
          spawnInterval: 600, // Overlap!
        );

      // ═══════════════════════════════════════════════════════════
      // LEVELS 6-8: 4×4 GRID (16 holes) - Intermediate
      // ═══════════════════════════════════════════════════════════
      case 6:
        return Level(
          levelNumber: 6,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 950,
          bombChance: 30,
          bombTimePenalty: 4,
          maxActiveMoles: 2,
          spawnInterval: 550,
        );
      case 7:
        return Level(
          levelNumber: 7,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 900,
          bombChance: 35,
          bombTimePenalty: 5,
          maxActiveMoles: 2,
          spawnInterval: 500,
        );
      case 8:
        return Level(
          levelNumber: 8,
          gridRows: 4,
          gridColumns: 4,
          moleStayDuration: 900,
          bombChance: 40,
          bombTimePenalty: 5,
          maxActiveMoles: 3,
          spawnInterval: 350, // Fast enough for 3 overlapping moles
        );

      // ═══════════════════════════════════════════════════════════
      // LEVELS 9-10: 5×5 GRID (25 holes) - Expert
      // ═══════════════════════════════════════════════════════════
      case 9:
        return Level(
          levelNumber: 9,
          gridRows: 5,
          gridColumns: 5,
          moleStayDuration: 850,
          bombChance: 45,
          bombTimePenalty: 6,
          maxActiveMoles: 3,
          spawnInterval: 320,
        );
      case 10:
        return Level(
          levelNumber: 10,
          gridRows: 5,
          gridColumns: 5,
          moleStayDuration: 800,
          bombChance: 50,
          bombTimePenalty: 7,
          maxActiveMoles: 3,
          spawnInterval: 290,
        );

      default:
        return createLevel(1);
    }
  }
}
