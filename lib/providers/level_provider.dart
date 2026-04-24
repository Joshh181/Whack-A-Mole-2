import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/level.dart';
import '../services/storage_service.dart';

class LevelProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Level> _levels = [];
  int _currentLevel = 1;
  bool _isInitialized = false;
  
  List<Level> get levels => _levels;
  int get currentLevel => _currentLevel;
  bool get isInitialized => _isInitialized;

  LevelProvider() {
    _initializeDefaultLevels();
  }

  void _initializeDefaultLevels() {
    _levels = List.generate(10, (index) => Level.createLevel(index + 1));
  }

  Future<void> loadUserData() async {
    try {
      final String? levelsJson = await _storage.getLevelsData();
      
      if (levelsJson != null) {
        final List<dynamic> decoded = json.decode(levelsJson);
        final savedLevels = decoded.map((item) => Level.fromJson(item)).toList();
        
        // Preserve player progress while using new grid configurations
        for (int i = 0; i < _levels.length && i < savedLevels.length; i++) {
          _levels[i].highScore = savedLevels[i].highScore;
          _levels[i].stars = savedLevels[i].stars;
          _levels[i].isUnlocked = savedLevels[i].isUnlocked;
        }
      }
      
      _currentLevel = await _storage.getCurrentLevel();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading levels: $e');
      // If error occurs, we keep the default levels generated in constructor
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> saveLevels() async {
    try {
      final String encoded = json.encode(_levels.map((l) => l.toJson()).toList());
      await _storage.saveLevelsData(encoded);
      await _storage.saveCurrentLevel(_currentLevel);
    } catch (e) {
      debugPrint('Error saving levels: $e');
    }
  }

  void setCurrentLevel(int levelNumber) {
    _currentLevel = levelNumber;
    saveLevels();
    notifyListeners();
  }

  void completeLevel(int levelNumber, int score) {
    final levelIndex = _levels.indexWhere((l) => l.levelNumber == levelNumber);
    if (levelIndex != -1) {
      _levels[levelIndex].updateScore(score);
      
      if (_levels[levelIndex].stars > 0 && levelIndex + 1 < _levels.length) {
        _levels[levelIndex + 1].isUnlocked = true;
      }
      
      saveLevels();
      notifyListeners();
    }
  }

  Level? getLevel(int levelNumber) {
    return _levels.firstWhere((l) => l.levelNumber == levelNumber, orElse: () => _levels.first);
  }

  void resetAllLevels() {
    _initializeDefaultLevels();
    _currentLevel = 1;
    saveLevels();
    notifyListeners();
  }

  void clearCache() {
    _isInitialized = false;
    _initializeDefaultLevels();
    notifyListeners();
  }
}