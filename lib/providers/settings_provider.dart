import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final AudioService _audioService = AudioService();
  
  bool _soundEffects = true;
  bool _backgroundMusic = true;
  bool _pushNotifications = true;
  bool _hapticFeedback = true;
  String _language = 'English';

  // Getters
  bool get soundEffects => _soundEffects;
  bool get backgroundMusic => _backgroundMusic;
  bool get pushNotifications => _pushNotifications;
  bool get hapticFeedback => _hapticFeedback;
  String get language => _language;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final soundFx = await _storage.getBool(AppConstants.keySoundEffects);
      _soundEffects = soundFx;
      
      final bgMusic = await _storage.getBool(AppConstants.keyBackgroundMusic);
      _backgroundMusic = bgMusic;
      
      final pushNotif = await _storage.getBool(AppConstants.keyPushNotifications);
      _pushNotifications = pushNotif;
      
      final lang = await _storage.getString(AppConstants.keyLanguage);
      _language = lang;

      final haptic = await _storage.getBool(AppConstants.keyHapticFeedback);
      _hapticFeedback = haptic;
      
      // Sync AudioService with loaded settings
      _audioService.setSoundEffectsEnabled(_soundEffects);
      _audioService.setBackgroundMusicEnabled(_backgroundMusic);

      notifyListeners();
    } catch (e) {
      // If there's an error loading settings, use defaults
      print('Error loading settings: $e');
    }
  }

  Future<void> toggleSoundEffects() async {
    _soundEffects = !_soundEffects;
    _audioService.setSoundEffectsEnabled(_soundEffects);
    await _storage.saveBool(AppConstants.keySoundEffects, _soundEffects);
    notifyListeners();
  }

  Future<void> toggleBackgroundMusic() async {
    _backgroundMusic = !_backgroundMusic;
    _audioService.setBackgroundMusicEnabled(_backgroundMusic);
    await _storage.saveBool(AppConstants.keyBackgroundMusic, _backgroundMusic);
    notifyListeners();
  }

  Future<void> togglePushNotifications() async {
    _pushNotifications = !_pushNotifications;
    await _storage.saveBool(AppConstants.keyPushNotifications, _pushNotifications);
    notifyListeners();
  }

  Future<void> setLanguage(String newLanguage) async {
    _language = newLanguage;
    await _storage.saveString(AppConstants.keyLanguage, _language);
    notifyListeners();
  }

  Future<void> toggleHapticFeedback() async {
    _hapticFeedback = !_hapticFeedback;
    await _storage.saveBool(AppConstants.keyHapticFeedback, _hapticFeedback);
    notifyListeners();
  }
}