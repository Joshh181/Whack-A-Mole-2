import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Separate players so effects and music don't interfere
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Pool of effect players to allow overlapping sounds
  final List<AudioPlayer> _effectPlayers = List.generate(4, (_) => AudioPlayer());
  int _currentEffectPlayer = 0;

  bool _soundEffectsEnabled = true;
  bool _backgroundMusicEnabled = true;

  // ─── SETTINGS ─────────────────────────────────────────────

  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;

  void setSoundEffectsEnabled(bool enabled) {
    _soundEffectsEnabled = enabled;
    if (!enabled) {
      for (final player in _effectPlayers) {
        player.stop();
      }
    }
  }

  void setBackgroundMusicEnabled(bool enabled) {
    _backgroundMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  // ─── INTERNAL HELPERS ─────────────────────────────────────

  AudioPlayer _getNextEffectPlayer() {
    final player = _effectPlayers[_currentEffectPlayer];
    _currentEffectPlayer = (_currentEffectPlayer + 1) % _effectPlayers.length;
    return player;
  }

  Future<void> _playEffect(String filename) async {
    if (!_soundEffectsEnabled) return;
    try {
      final player = _getNextEffectPlayer();
      await player.stop();
      await player.play(AssetSource('sounds/$filename'));
    } catch (e) {
      debugPrint('🔇 Error playing $filename: $e');
    }
  }

  // ─── GAME SOUND EFFECTS ──────────────────────────────────

  /// Play when player whacks a mole successfully
  Future<void> playWhackSound() => _playEffect('whack.wav');

  /// Play when player hits a bomb
  Future<void> playBombSound() => _playEffect('bomb.wav');

  /// Play when game ends
  Future<void> playGameOverSound() => _playEffect('game_over.wav');

  /// Play when tapping any UI button
  Future<void> playButtonClick() => _playEffect('button_click.wav');

  /// Play when activating a power-up
  Future<void> playPowerUpSound() => _playEffect('powerup.wav');

  /// Play when unlocking an achievement
  Future<void> playAchievementSound() => _playEffect('achievement.wav');

  // ─── BACKGROUND MUSIC ─────────────────────────────────────

  Future<void> playBackgroundMusic() async {
    if (!_backgroundMusicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play(AssetSource('sounds/background.wav'));
    } catch (e) {
      debugPrint('🔇 Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('🔇 Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      debugPrint('🔇 Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_backgroundMusicEnabled) return;
    try {
      await _musicPlayer.resume();
    } catch (e) {
      debugPrint('🔇 Error resuming background music: $e');
    }
  }

  // ─── CLEANUP ──────────────────────────────────────────────

  void dispose() {
    for (final player in _effectPlayers) {
      player.dispose();
    }
    _musicPlayer.dispose();
  }
}