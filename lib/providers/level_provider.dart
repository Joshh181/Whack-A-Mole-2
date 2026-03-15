import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/level.dart';

class LevelProvider extends ChangeNotifier {
  List<Level> _levels = [];
  int _currentLevel = 1;
  
  List<Level> get levels => _levels;
  int get currentLevel => _currentLevel;

  LevelProvider() {
    _initializeLevels();
  }

  void _initializeLevels() {
    // ✅ Generate 10 levels instead of 5
    _levels = List.generate(10, (index) => Level.createLevel(index + 1));
    loadLevels();
  }

  Future<void> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? levelsJson = prefs.getString('levels_data');
    
    if (levelsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(levelsJson);
        final savedLevels = decoded.map((item) => Level.fromJson(item)).toList();
        
        // ✅ Preserve player progress while using new grid configurations
        for (int i = 0; i < _levels.length && i < savedLevels.length; i++) {
          _levels[i].highScore = savedLevels[i].highScore;
          _levels[i].stars = savedLevels[i].stars;
          _levels[i].isUnlocked = savedLevels[i].isUnlocked;
        }
        
        // ✅ Save the updated configuration
        await saveLevels();
        
      } catch (e) {
        debugPrint('Error loading levels: $e');
        _initializeLevels();
      }
    }
    
    _currentLevel = prefs.getInt('current_level') ?? 1;
    notifyListeners();
  }

  Future<void> saveLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_levels.map((l) => l.toJson()).toList());
    await prefs.setString('levels_data', encoded);
    await prefs.setInt('current_level', _currentLevel);
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
    try {
      return _levels.firstWhere((l) => l.levelNumber == levelNumber);
    } catch (e) {
      return null;
    }
  }

  void resetAllLevels() {
    _initializeLevels();
    _currentLevel = 1;
    saveLevels();
    notifyListeners();
  }
}