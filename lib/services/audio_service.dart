import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEffectsEnabled = true;
  bool _backgroundMusicEnabled = true;

  void setSoundEffectsEnabled(bool enabled) {
    _soundEffectsEnabled = enabled;
  }

  void setBackgroundMusicEnabled(bool enabled) {
    _backgroundMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  Future<void> playWhackSound() async {
    if (_soundEffectsEnabled) {
      try {
        await _effectsPlayer.play(AssetSource('sounds/whack.mp3'));
      } catch (e) {
        print('Error playing whack sound: $e');
      }
    }
  }

  Future<void> playButtonClick() async {
    if (_soundEffectsEnabled) {
      try {
        await _effectsPlayer.play(AssetSource('sounds/button_click.mp3'));
      } catch (e) {
        print('Error playing button click sound: $e');
      }
    }
  }

  Future<void> playBackgroundMusic() async {
    if (_backgroundMusicEnabled) {
      try {
        await _musicPlayer.play(
          AssetSource('sounds/background.mp3'),
          volume: 0.3,
        );
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (_backgroundMusicEnabled) {
      try {
        await _musicPlayer.resume();
      } catch (e) {
        print('Error resuming background music: $e');
      }
    }
  }

  void dispose() {
    _effectsPlayer.dispose();
    _musicPlayer.dispose();
  }
}