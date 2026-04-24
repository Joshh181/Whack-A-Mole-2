class GameState {
  int currentScore;
  int timeRemaining;
  bool isPlaying;
  bool isPaused;
  int activeMoleIndex;
  bool isBomb;
  List<bool> activePowerUps;

  GameState({
    this.currentScore = 0,
    this.timeRemaining = 50,
    this.isPlaying = false,
    this.isPaused = false,
    this.activeMoleIndex = -1,
    this.isBomb = false,
    List<bool>? activePowerUps,
  }) : activePowerUps = activePowerUps ?? [false, false, false];

  void reset() {
    currentScore = 0;
    timeRemaining = 50;
    isPlaying = false;
    isPaused = false;
    activeMoleIndex = -1;
    isBomb = false;
    activePowerUps = [false, false, false];
  }

  void addTime(int seconds) {
    timeRemaining += seconds;
  }

  void addScore(int points, {bool doublePoints = false}) {
    currentScore += doublePoints ? points * 2 : points;
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