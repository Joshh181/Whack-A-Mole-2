class GameState {
  int currentScore;
  int timeRemaining;
  bool isPlaying;
  bool isPaused;
  List<bool> activePowerUps;

  // Multiple active moles: key = hole index, value = true if bomb
  Map<int, bool> activeMoles;

  // Combo & Multiplier
  int comboCount;
  int lastScoreEarned; // Points earned on the last hit (for floating text)

  GameState({
    this.currentScore = 0,
    this.timeRemaining = 50,
    this.isPlaying = false,
    this.isPaused = false,
    this.comboCount = 0,
    this.lastScoreEarned = 0,
    Map<int, bool>? activeMoles,
    List<bool>? activePowerUps,
  }) : activeMoles = activeMoles ?? {},
       activePowerUps = activePowerUps ?? [false, false, false];

  /// Combo multiplier tiers: 1x (0-4), 2x (5-9), 3x (10-14), 4x (15+)
  int get comboMultiplier {
    if (comboCount >= 15) return 4;
    if (comboCount >= 10) return 3;
    if (comboCount >= 5) return 2;
    return 1;
  }

  void incrementCombo() {
    comboCount++;
  }

  void resetCombo() {
    comboCount = 0;
  }

  void reset() {
    currentScore = 0;
    timeRemaining = 50;
    isPlaying = false;
    isPaused = false;
    activeMoles = {};
    activePowerUps = [false, false, false];
    comboCount = 0;
    lastScoreEarned = 0;
  }

  void addTime(int seconds) {
    timeRemaining += seconds;
  }

  /// Adds score with combo multiplier and optional double-points power-up.
  void addScore(int points, {bool doublePoints = false}) {
    int earned = points * comboMultiplier;
    if (doublePoints) earned *= 2;
    lastScoreEarned = earned;
    currentScore += earned;
  }

  void activatePowerUp(int index) {
    if (index >= 0 && index < activePowerUps.length) {
      activePowerUps[index] = true;
    }
  }

  void deactivatePowerUp(int index) {
    if (index >= 0 && index < activePowerUps.length) {
      activePowerUps[index] = false;
    }
  }

  bool isPowerUpActive(int index) {
    if (index >= 0 && index < activePowerUps.length) {
      return activePowerUps[index];
    }
    return false;
  }
}