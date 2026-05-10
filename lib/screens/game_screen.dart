import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/game_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/level.dart';
import '../config/app_colors.dart';
import '../widgets/pause_dialog.dart';
import '../widgets/animated_mole_hole.dart';
import '../widgets/floating_score_text.dart';
import 'dart:math';
import '../providers/level_provider.dart';
import '../services/audio_service.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider gameProvider;
  final AudioService _audioService = AudioService();
  final Set<String> _completedAchievements = {};
  bool _scoreSubmitted = false;
  int _coinsEarned = 0;
  Timer? _powerUpTickTimer;

  // Floating score text overlays
  final List<Widget> _floatingTexts = [];
  int _floatingTextId = 0;

  // Mallet smash animation state
  final Map<int, _MalletSmash> _malletSmashes = {};

  // Grid key for position calculations
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Tick every 50ms to smoothly update power-up countdown rings
    _powerUpTickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameProvider = Provider.of<GameProvider>(context, listen: false);
      
      // Ensure we don't show popups for achievements earned in previous sessions
      for (var achievement in gameProvider.achievements) {
        if (achievement.isCompleted) {
          _completedAchievements.add(achievement.id);
        }
      }

      gameProvider.startGameWithLevel(widget.level);
      gameProvider.addListener(_onGameProviderChanged);
      // 🔊 Start background music when game begins
      _audioService.playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    _powerUpTickTimer?.cancel();
    gameProvider.removeListener(_onGameProviderChanged);
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _onGameProviderChanged() {
    _checkForNewAchievements();

    if (!gameProvider.gameState.isPlaying && !_scoreSubmitted) {
      final int score = gameProvider.finalScore;
      debugPrint('🎯 Game ended — finalScore: $score');
      // 🔊 Stop music and play appropriate end sound
      _audioService.stopBackgroundMusic();
      final int stars = widget.level.calculateStars(score);
      if (stars > 0) {
        _audioService.playGameCompletedSound();
      } else {
        _audioService.playGameOverSound();
      }
      if (score > 0) {
        _scoreSubmitted = true;
        
        // 💰 Calculate and award coins
        final shopProvider = Provider.of<ShopProvider>(context, listen: false);
        int sessionCoins = (score / 10).floor(); // 1 coin per 10 points
        if (stars == 1) sessionCoins += 10;
        if (stars == 2) sessionCoins += 25;
        if (stars == 3) sessionCoins += 50;
        
        setState(() {
          _coinsEarned = sessionCoins;
        });
        
        if (sessionCoins > 0) {
          shopProvider.addCoins(sessionCoins);
        }

        _submitScoreToLeaderboard(score);
        final levelProvider =
            Provider.of<LevelProvider>(context, listen: false);
        levelProvider.completeLevel(widget.level.levelNumber, score);
      }
    }
  }

  void _checkForNewAchievements() {
    final achievements = gameProvider.achievements;
    for (var achievement in achievements) {
      if (achievement.isCompleted &&
          !_completedAchievements.contains(achievement.id)) {
        _completedAchievements.add(achievement.id);
        _showAchievementPopup(achievement);
      }
    }
  }

  void _showAchievementPopup(Achievement achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade400,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      achievement.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🎉 ACHIEVEMENT!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        achievement.description,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> _submitScoreToLeaderboard(int score) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('No logged-in user, skipping leaderboard submission');
        return;
      }

      final username = user.userMetadata?['username'] as String? ??
          user.userMetadata?['name'] as String? ??
          user.email ??
          'Anonymous';

      debugPrint('Submitting score: $score for user: $username');

      final leaderboardProvider =
          Provider.of<LeaderboardProvider>(context, listen: false);

      final success = await leaderboardProvider.submitScore(
        userId: user.id,
        username: username,
        score: score,
      );

      debugPrint(success
          ? '✅ Score submitted successfully!'
          : '❌ Failed to submit score');
    } catch (e) {
      debugPrint('❌ Error submitting score: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final gp = Provider.of<GameProvider>(context, listen: false);
        if (gp.gameState.isPlaying) {
          gp.pauseGame();
          _audioService.pauseBackgroundMusic();
          _showPauseDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BACKGROUND.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Consumer<GameProvider>(
              builder: (context, gp, child) {
                if (!gp.gameState.isPlaying) {
                  return _buildGameOverScreen(gp);
                }
                return _buildGameScreen(gp);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen(GameProvider gp) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LV ${widget.level.levelNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${gp.gameState.currentScore}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ═══ COMBO INDICATOR ═══
                  if (gp.comboCount >= 2)
                    _buildComboIndicator(gp),
                  Consumer<ShopProvider>(
                    builder: (context, shopProvider, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade400,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              '${shopProvider.coins}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      gp.pauseGame();
                      _audioService.pauseBackgroundMusic();
                      _showPauseDialog();
                    },
                    icon: const Icon(
                      Icons.pause,
                      size: 36,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 160),
                child: GridView.builder(
                  key: _gridKey,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.none,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.level.gridColumns,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: widget.level.totalHoles,
                  itemBuilder: (context, index) {
                    bool isMoleActive = gp.gameState.activeMoles.containsKey(index);
                    bool hasBomb = gp.gameState.activeMoles[index] == true;

                    return _buildHole(index, isMoleActive, hasBomb, gp);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: gp.gameState.timeRemaining / 50,
                      minHeight: 30,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gp.gameState.timeRemaining > 10
                            ? Colors.yellow.shade700
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${gp.gameState.timeRemaining}s',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            _buildPowerUps(gp),
            const SizedBox(height: 20),
          ],
        ),
        // ═══ FLOATING SCORE TEXT OVERLAYS ═══
        ..._floatingTexts,
        // ═══ MALLET SMASH OVERLAYS ═══
        ..._malletSmashes.entries.map((e) => _buildMalletSmashWidget(e.value)),
      ],
    );
  }

  // ═══ COMBO INDICATOR WIDGET ═══
  Widget _buildComboIndicator(GameProvider gp) {
    final combo = gp.comboCount;
    final multiplier = gp.comboMultiplier;

    Color bgColor;
    Color textColor;
    if (multiplier >= 4) {
      bgColor = Colors.red.shade700;
      textColor = Colors.white;
    } else if (multiplier >= 3) {
      bgColor = Colors.orange.shade700;
      textColor = Colors.white;
    } else if (multiplier >= 2) {
      bgColor = Colors.amber.shade700;
      textColor = Colors.black87;
    } else {
      bgColor = Colors.blue.shade600;
      textColor = Colors.white;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 200),
      key: ValueKey(combo), // restart animation on each combo change
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  multiplier >= 3 ? '🔥' : '⚡',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  'x$combo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${multiplier}x',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHole(
      int index, bool isMoleActive, bool hasBomb, GameProvider gp) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        final moleImagePath = shopProvider.getMoleImagePath();
        final bombImagePath = shopProvider.getBombImagePath();
        final isOriginalMole = moleImagePath.contains('33121063782.png');

        return AnimatedMoleHole(
          key: ValueKey(index),
          isMoleActive: isMoleActive,
          hasBomb: hasBomb,
          gridColumns: widget.level.gridColumns,
          moleImagePath: moleImagePath,
          bombImagePath: bombImagePath,
          isOriginalMole: isOriginalMole,
          onTap: () {
            if (hasBomb) {
              _audioService.playBombSound();
              // Remove the bomb from active moles before applying penalty
              gp.gameState.activeMoles.remove(index);
              gp.hitBomb(widget.level.bombTimePenalty);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('💣 BOMB! -${widget.level.bombTimePenalty} seconds!'),
                  duration: const Duration(milliseconds: 800),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              _audioService.playWhackSound();
              gp.whackMole(index);
              // Spawn floating text + mallet smash at hit position
              _spawnFloatingText(context, index, gp);
              _spawnMalletSmash(context, index, shopProvider);
            }
          },
        );
      },
    );
  }

  /// Spawns a floating score text at the given hole index position.
  void _spawnFloatingText(BuildContext ctx, int holeIndex, GameProvider gp) {
    final pos = _getHoleScreenPosition(holeIndex);
    if (pos == null) return;

    final id = _floatingTextId++;
    final widget = FloatingScoreText(
      key: ValueKey('float_$id'),
      scoreEarned: gp.gameState.lastScoreEarned,
      comboCount: gp.comboCount,
      multiplier: gp.comboMultiplier,
      position: pos,
      onComplete: () {
        if (mounted) {
          setState(() {
            _floatingTexts.removeWhere((w) => w.key == ValueKey('float_$id'));
          });
        }
      },
    );

    setState(() {
      _floatingTexts.add(widget);
    });
  }

  /// Spawns a mallet smash emoji animation at the given hole index position.
  void _spawnMalletSmash(BuildContext ctx, int holeIndex, ShopProvider shopProvider) {
    final pos = _getHoleScreenPosition(holeIndex);
    if (pos == null) return;

    final smash = _MalletSmash(
      emoji: shopProvider.getEquippedMalletEmoji(),
      position: pos,
      createdAt: DateTime.now(),
    );

    setState(() {
      _malletSmashes[holeIndex] = smash;
    });

    // Remove after animation completes
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _malletSmashes.remove(holeIndex);
        });
      }
    });
  }

  /// Calculates the screen position of a hole in the grid.
  Offset? _getHoleScreenPosition(int holeIndex) {
    final gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox == null) return null;

    final gridPos = gridBox.localToGlobal(Offset.zero);
    final gridWidth = gridBox.size.width;
    final cols = this.widget.level.gridColumns;
    final cellWidth = gridWidth / cols;

    final row = holeIndex ~/ cols;
    final col = holeIndex % cols;

    // Position at center of the cell
    return Offset(
      gridPos.dx + (col * cellWidth) + (cellWidth / 2),
      gridPos.dy + (row * cellWidth) + (cellWidth / 2) - 30,
    );
  }

  /// Builds the mallet smash animation widget.
  Widget _buildMalletSmashWidget(_MalletSmash smash) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('smash_${smash.createdAt.millisecondsSinceEpoch}'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Scale: 2.0 -> 1.0 (slam down), then fade out
        final scale = 2.0 - value;
        final opacity = (1.0 - value).clamp(0.0, 1.0);
        final rotation = -0.4 + (value * 0.4); // swing from -0.4 rad to 0

        return Positioned(
          left: smash.position.dx - 25,
          top: smash.position.dy - 30,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: Text(
                    smash.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPowerUps(GameProvider gp) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        final powerUps = shopProvider.getPowerUpItems();
        if (powerUps.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerUpButton(
                emoji: '⏰',
                label: 'Extra Time',
                count: shopProvider.getPowerUpCount('extra_time'),
                isActive: gp.gameState.isPowerUpActive(0),
                remainingFraction: gp.getPowerUpRemainingFraction(0),
                onTap: () {
                  if (shopProvider.usePowerUp('extra_time')) {
                    _audioService.playPowerUpSound();
                    gp.usePowerUp(0);
                  }
                },
              ),
              _buildPowerUpButton(
                emoji: '✨',
                label: 'Double Pts',
                count: shopProvider.getPowerUpCount('double_points'),
                isActive: gp.gameState.isPowerUpActive(1),
                remainingFraction: gp.getPowerUpRemainingFraction(1),
                onTap: () {
                  if (shopProvider.usePowerUp('double_points')) {
                    _audioService.playPowerUpSound();
                    gp.usePowerUp(1);
                  }
                },
              ),
              _buildPowerUpButton(
                emoji: '🐌',
                label: 'Slow Mole',
                count: shopProvider.getPowerUpCount('slow_mole'),
                isActive: gp.gameState.isPowerUpActive(2),
                remainingFraction: gp.getPowerUpRemainingFraction(2),
                onTap: () {
                  if (shopProvider.usePowerUp('slow_mole')) {
                    _audioService.playPowerUpSound();
                    gp.usePowerUp(2);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPowerUpButton({
    required String emoji,
    required String label,
    required int count,
    required bool isActive,
    required double remainingFraction,
    required VoidCallback onTap,
  }) {
    bool canUse = count > 0;

    return Opacity(
      opacity: canUse ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: canUse && !isActive ? onTap : null,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Countdown ring (visible only when active)
                      if (isActive)
                        SizedBox(
                          width: 62,
                          height: 62,
                          child: CircularProgressIndicator(
                            value: remainingFraction,
                            strokeWidth: 4,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
                          ),
                        ),
                      // The power-up icon circle
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.orange : Colors.red.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'x$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(GameProvider gp) {
    final int finalScore = gp.finalScore;
    int stars = widget.level.calculateStars(finalScore);

    // Dynamic title based on performance
    final String titleText;
    final Color titleColor;
    if (stars == 0) {
      titleText = 'GAME OVER';
      titleColor = Colors.red;
    } else if (stars == 1) {
      titleText = 'NICE TRY!';
      titleColor = Colors.orange;
    } else if (stars == 2) {
      titleText = 'GREAT JOB!';
      titleColor = Colors.blue;
    } else {
      titleText = 'PERFECT!';
      titleColor = Colors.green;
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL ${widget.level.levelNumber}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titleText,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: index < stars ? Colors.amber : Colors.grey,
                  size: 50,
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              'Score: $finalScore',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_coinsEarned > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '+$_coinsEarned',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _scoreSubmitted = false;
                      _coinsEarned = 0;
                    });
                    _audioService.playButtonClick();
                    _audioService.playBackgroundMusic();
                    gp.restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.playButton,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'RETRY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _audioService.playButtonClick();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'LEVELS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PauseDialog(),
    );
  }
}

/// Simple data class for mallet smash animations.
class _MalletSmash {
  final String emoji;
  final Offset position;
  final DateTime createdAt;

  _MalletSmash({
    required this.emoji,
    required this.position,
    required this.createdAt,
  });
}