import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/game_state.dart';
import '../models/level.dart';
import '../services/storage_service.dart';

// Simple Achievement model used by the UI
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
      'currentProgress': currentProgress,
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

class GameProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final Random _random = Random();

  GameState _gameState = GameState();
  Level? _currentLevel;
  int _highScore = 0;
  Timer? _gameTimer;
  Timer? _moleTimer;
  int _currentMoleId = 0;
  int _totalMolesWhacked = 0;
  int _gamesPlayed = 0;
  int _currentCombo = 0;
  int _maxCombo = 0;

  // ✅ Stores the final score at the moment the game ends — safe to read anytime
  int _finalScore = 0;
  int get finalScore => _finalScore;

  GameState get gameState => _gameState;
  int get highScore => _highScore;
  Level? get currentLevel => _currentLevel;

  final List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  GameProvider() {
    _initializeAchievements();
    _loadHighScore();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final Map<String, int> savedProgress = await _storage.getAchievementProgress();
    bool hasUpdates = false;
    for (var achievement in _achievements) {
      if (savedProgress.containsKey(achievement.id)) {
        achievement.currentProgress = savedProgress[achievement.id]!;
        hasUpdates = true;
      }
    }
    if (hasUpdates) notifyListeners();
  }

  Future<void> _saveAchievements() async {
    final Map<String, int> progressMap = {
      for (var a in _achievements) a.id: a.currentProgress
    };
    await _storage.saveAchievementProgress(progressMap);
  }

  void _updateAchievement(String id, int progress) {
    final achievement = _achievements.firstWhere(
      (a) => a.id == id,
      orElse: () => Achievement(
        id: '',
        title: '',
        description: '',
        threshold: 0,
        iconEmoji: '',
      ),
    );

    if (achievement.id.isNotEmpty) {
      if (progress > achievement.threshold) {
        progress = achievement.threshold;
      }

      if (achievement.currentProgress < progress) {
        achievement.currentProgress = progress;
        _saveAchievements();
        notifyListeners();
      }
    }
  }

  void _checkScoreAchievements(int score) {
    if (score >= 10) {
      _updateAchievement('first_whack', 1);
    }
    if (score >= 100) {
      _updateAchievement('score_100', score);
    }
    if (score >= 500) {
      _updateAchievement('master_whacker', score);
    }
  }

  void _checkComboAchievements() {
    if (_currentCombo >= 15) {
      _updateAchievement('on_fire', _currentCombo);
    }
  }

  void _initializeAchievements() {
    _achievements.addAll([
      Achievement(
        id: 'first_whack',
        iconEmoji: '🎯',
        title: 'First Whack',
        description: 'Whack your first mole',
        threshold: 1,
        currentProgress: 0,
      ),
      Achievement(
        id: 'score_100',
        iconEmoji: '💯',
        title: 'Century Club',
        description: 'Score 100 points in a single game',
        threshold: 100,
        currentProgress: 0,
      ),
      Achievement(
        id: 'speed_demon',
        iconEmoji: '⚡',
        title: 'Speed Demon',
        description: 'Whack 10 moles in 10 seconds',
        threshold: 10,
        currentProgress: 0,
      ),
      Achievement(
        id: 'master_whacker',
        iconEmoji: '🏆',
        title: 'Master Whacker',
        description: 'Reach a score of 500',
        threshold: 500,
        currentProgress: 0,
      ),
      Achievement(
        id: 'on_fire',
        iconEmoji: '🔥',
        title: 'On Fire',
        description: 'Get a 15 whack combo',
        threshold: 15,
        currentProgress: 0,
      ),
      Achievement(
        id: 'perfect_game',
        iconEmoji: '💎',
        title: 'Perfect Game',
        description: 'Complete a level without missing',
        threshold: 1,
        currentProgress: 0,
      ),
      Achievement(
        id: 'three_stars',
        iconEmoji: '🌟',
        title: 'Three Stars',
        description: 'Get 3 stars on any level',
        threshold: 1,
        currentProgress: 0,
      ),
      Achievement(
        id: 'dedicated_player',
        iconEmoji: '🎮',
        title: 'Dedicated Player',
        description: 'Play 50 games',
        threshold: 50,
        currentProgress: 0,
      ),
    ]);
  }

  Future<void> _loadHighScore() async {
    _highScore = await _storage.getHighScore();
    notifyListeners();
  }

  void startGame() {
    _gameState.reset();
    _finalScore = 0; // ✅ Reset final score
    _gameState.isPlaying = true;
    _startGameTimers();
    notifyListeners();
  }

  void startGameWithLevel(Level level) {
    _currentLevel = level;
    _gameState.reset();
    _finalScore = 0; // ✅ Reset final score
    _gameState.timeRemaining = 50;
    _gameState.isPlaying = true;
    _currentMoleId = 0;
    _currentCombo = 0;
    _maxCombo = 0;
    _gamesPlayed++;
    _updateAchievement('dedicated_player', _gamesPlayed);
    _startGameTimers(level);
    notifyListeners();
  }

  void _startGameTimers([Level? level]) {
    _gameTimer?.cancel();
    _moleTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.timeRemaining > 0 && !_gameState.isPaused) {
        _gameState.timeRemaining -= 1;
        notifyListeners();
      } else if (_gameState.timeRemaining <= 0) {
        endGame();
      }
    });

    int moleDuration = level?.moleStayDuration ?? 1300;
    _moleTimer = Timer.periodic(Duration(milliseconds: moleDuration + 300), (timer) {
      if (!_gameState.isPaused && _gameState.isPlaying) {
        _spawnMole(level);
      }
    });

    if (_gameState.isPlaying) {
      _spawnMole(level);
    }
  }

  void _spawnMole(Level? level) {
    int totalHoles = level?.totalHoles ?? 12;
    _gameState.activeMoleIndex = _random.nextInt(totalHoles);

    _currentMoleId++;
    final int thisMoleId = _currentMoleId;

    notifyListeners();

    int moleDuration = level?.moleStayDuration ?? 1300;
    Future.delayed(Duration(milliseconds: moleDuration), () {
      if (_gameState.activeMoleIndex != -1 && thisMoleId == _currentMoleId) {
        _gameState.activeMoleIndex = -1;
        _currentCombo = 0;
        notifyListeners();
      }
    });
  }

  void whackMole(int index) {
    if (_gameState.activeMoleIndex == index) {
      bool doublePoints = _gameState.isPowerUpActive(1);
      _gameState.addScore(10, doublePoints: doublePoints);
      _gameState.activeMoleIndex = -1;
      _currentMoleId++;

      _totalMolesWhacked++;
      _currentCombo++;
      if (_currentCombo > _maxCombo) {
        _maxCombo = _currentCombo;
      }

      _updateAchievement('first_whack', _totalMolesWhacked);
      _checkScoreAchievements(_gameState.currentScore);
      _checkComboAchievements();

      notifyListeners();
    }
  }

  void hitBomb(int timePenalty) {
    _gameState.timeRemaining -= timePenalty;
    if (_gameState.timeRemaining < 0) {
      _gameState.timeRemaining = 0;
    }
    _gameState.activeMoleIndex = -1;
    _currentMoleId++;
    notifyListeners();
  }

  void usePowerUp(int index) {
    if (index == 0) {
      _gameState.addTime(10);
      _gameState.activatePowerUp(0);
      Future.delayed(const Duration(seconds: 1), () {
        _gameState.deactivatePowerUp(0);
        notifyListeners();
      });
    } else if (index == 1) {
      _gameState.activatePowerUp(1);
      Future.delayed(const Duration(seconds: 10), () {
        _gameState.deactivatePowerUp(1);
        notifyListeners();
      });
    } else if (index == 2) {
      _gameState.activatePowerUp(2);

      _moleTimer?.cancel();
      int slowerDuration = ((currentLevel?.moleStayDuration ?? 1300) * 1.5).toInt();
      _moleTimer = Timer.periodic(Duration(milliseconds: slowerDuration + 300), (timer) {
        if (!_gameState.isPaused && _gameState.isPlaying) {
          _spawnMole(currentLevel);
        }
      });

      Future.delayed(const Duration(seconds: 10), () {
        _gameState.deactivatePowerUp(2);

        _moleTimer?.cancel();
        int normalDuration = currentLevel?.moleStayDuration ?? 1300;
        _moleTimer = Timer.periodic(Duration(milliseconds: normalDuration + 300), (timer) {
          if (!_gameState.isPaused && _gameState.isPlaying) {
            _spawnMole(currentLevel);
          }
        });

        notifyListeners();
      });
    }
    notifyListeners();
  }

  void pauseGame() {
    _gameState.isPaused = true;
    notifyListeners();
  }

  void resumeGame() {
    _gameState.isPaused = false;
    notifyListeners();
  }

  void endGame() {
    // ✅ Capture the score FIRST before any state changes
    _finalScore = _gameState.currentScore;
    debugPrint('=== endGame() called — finalScore: $_finalScore ===');

    _gameState.isPlaying = false;
    _gameTimer?.cancel();
    _moleTimer?.cancel();

    if (_finalScore > _highScore) {
      _highScore = _finalScore;
      _storage.saveHighScore(_highScore);
    }

    if (_currentLevel != null) {
      int stars = _currentLevel!.calculateStars(_finalScore);
      if (stars >= 3) {
        _updateAchievement('three_stars', 1);
      }
    }

    _checkScoreAchievements(_finalScore);
    if (_maxCombo >= 15) {
      _updateAchievement('on_fire', _maxCombo);
    }

    notifyListeners();
  }

  void restartGame() {
    if (_currentLevel != null) {
      startGameWithLevel(_currentLevel!);
    } else {
      startGame();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    super.dispose();
  }
}