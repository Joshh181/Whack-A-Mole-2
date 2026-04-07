import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  // Players
  late final AudioPlayer _musicPlayer;
  late final List<AudioPlayer> _effectPlayers;
  bool _initialized = false;

  AudioService._internal();

  /// Must be called before playing any audio to ensure correct AudioContext
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // 1. Allow music + SFX to coexist — prevent Android/iOS audio focus stealing
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        audioMode: AndroidAudioMode.normal,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const {},
      ),
    ));

    // 2. Instantiate players AFTER global context is set
    _musicPlayer = AudioPlayer();
    _effectPlayers = List.generate(4, (_) => AudioPlayer());

    _initialized = true;
  }

  int _currentEffectPlayer = 0;

  bool _soundEffectsEnabled = true;
  bool _backgroundMusicEnabled = true;
  bool _isMusicPlaying = false;
  bool get isMusicPlaying => _isMusicPlaying;

  static const double _normalVolume = 0.3;

  // ─── SETTINGS ─────────────────────────────────────────────

  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;

  void setSoundEffectsEnabled(bool enabled) {
    _soundEffectsEnabled = enabled;
    if (!enabled && _initialized) {
      for (final player in _effectPlayers) {
        player.stop();
      }
    }
  }

  void setBackgroundMusicEnabled(bool enabled) {
    _backgroundMusicEnabled = enabled;
    if (!enabled && _initialized) {
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
      await _ensureInitialized();
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

  /// Play when game ends with 0 stars
  Future<void> playGameOverSound() => _playEffect('game_over.wav');

  /// Play when game ends with 1+ stars
  Future<void> playGameCompletedSound() => _playEffect('GAME-COMPLETED.wav');

  /// Play when tapping any UI button
  Future<void> playButtonClick() => _playEffect('button_click.wav');

  /// Play when activating a power-up
  Future<void> playPowerUpSound() => _playEffect('powerup.wav');

  /// Play when an action is invalid (e.g. not enough coins)
  Future<void> playError() => _playEffect('game_over.wav');

  /// Play when a purchase is completed successfully
  Future<void> playPurchase() => _playEffect('GAME-COMPLETED.wav');

  // ─── BACKGROUND MUSIC ─────────────────────────────────────

  Future<void> playBackgroundMusic() async {
    if (!_backgroundMusicEnabled) return;
    try {
      await _ensureInitialized();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_normalVolume);
      await _musicPlayer.play(AssetSource('sounds/littleroot_town.mp3'));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('🔇 Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      _isMusicPlaying = false;
      if (_initialized) {
        await _musicPlayer.stop();
      }
    } catch (e) {
      debugPrint('🔇 Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      _isMusicPlaying = false;
      if (_initialized) {
        await _musicPlayer.pause();
      }
    } catch (e) {
      debugPrint('🔇 Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_backgroundMusicEnabled) return;
    try {
      await _ensureInitialized();
      await _musicPlayer.resume();
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('🔇 Error resuming background music: $e');
    }
  }

  // ─── CLEANUP ──────────────────────────────────────────────

  void dispose() {
    if (_initialized) {
      for (final player in _effectPlayers) {
        player.dispose();
      }
      _musicPlayer.dispose();
    }
  }
}