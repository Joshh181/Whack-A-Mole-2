import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/game_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/level.dart';
import '../config/app_colors.dart';
import '../widgets/pause_dialog.dart';
import 'dart:math';
import '../providers/level_provider.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider gameProvider;
  Set<int> bombMoles = {};
  Random random = Random();
  Set<String> _completedAchievements = {};
  bool _scoreSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.startGameWithLevel(widget.level);
      gameProvider.addListener(_onGameProviderChanged);
    });
  }

  @override
  void dispose() {
    gameProvider.removeListener(_onGameProviderChanged);
    super.dispose();
  }

  void _onGameProviderChanged() {
    _checkForNewAchievements();

    if (!gameProvider.gameState.isPlaying && !_scoreSubmitted) {
      final int score = gameProvider.finalScore;
      debugPrint('🎯 Game ended — finalScore: $score');
      if (score > 0) {
        _scoreSubmitted = true;
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

  void _showAchievementPopup(achievement) {
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

  // ✅ Dynamic sizing based on grid size
  double _getMoleSize() {
    int columns = widget.level.gridColumns;
    if (columns == 3) return 170.0;  // 3×3 grid
    if (columns == 4) return 130.0;  // 4×4 grid
    return 100.0;  // 5×5 grid
  }

  double _getTopPosition(bool isActive) {
    if (!isActive) return 500.0;
    int columns = widget.level.gridColumns;
    if (columns == 3) return -25.0;
    if (columns == 4) return -25.0;  // ✅ Raised to match 3×3 centering
    return -15.0;  // ✅ Raised for 5×5 grid
  }

  double _getBombSize() {
    int columns = widget.level.gridColumns;
    if (columns == 3) return 70.0;
    if (columns == 4) return 55.0;
    return 45.0;
  }

  double _getBombTopPosition(bool isActive) {
    if (!isActive) return 500.0;
    int columns = widget.level.gridColumns;
    if (columns == 3) return -1.0;
    if (columns == 4) return -1.0;  // ✅ Raised to match 3×3
    return -5.0;  // ✅ Raised for 5×5 grid
  }

  double _getSkinPositionOffset() {
    int columns = widget.level.gridColumns;
    if (columns == 3) return 20.0;
    if (columns == 4) return 15.0;
    return 12.0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final gp = Provider.of<GameProvider>(context, listen: false);
        if (gp.gameState.isPlaying) {
          gp.pauseGame();
          _showPauseDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB),
                Color(0xFF32CD32),
              ],
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
    return Column(
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
            padding: const EdgeInsets.only(left: 8, right: 8, top: 40),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.level.gridColumns,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1.0,
              ),
              itemCount: widget.level.totalHoles,
              itemBuilder: (context, index) {
                bool isMoleActive = gp.gameState.activeMoleIndex == index;
                bool hasBomb = bombMoles.contains(index);

                if (isMoleActive &&
                    !bombMoles.contains(index) &&
                    widget.level.bombChance > 0) {
                  if (random.nextInt(100) < widget.level.bombChance) {
                    bombMoles.add(index);
                    hasBomb = true;
                  }
                }

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
    );
  }

  Widget _buildHole(
      int index, bool isMoleActive, bool hasBomb, GameProvider gp) {
    final moleSize = _getMoleSize();
    final moleTopPosition = _getTopPosition(isMoleActive);
    final bombSize = _getBombSize();
    final bombTopPosition = _getBombTopPosition(isMoleActive);
    final skinPositionOffset = _getSkinPositionOffset();

    return GestureDetector(
      onTap: () {
        if (isMoleActive) {
          if (hasBomb) {
            gp.hitBomb(widget.level.bombTimePenalty);
            bombMoles.remove(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('💣 BOMB! -${widget.level.bombTimePenalty} seconds!'),
                duration: const Duration(milliseconds: 800),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            gp.whackMole(index);
          }
        }
      },
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/HOLE.png',
            fit: BoxFit.contain,
          ),
          if (hasBomb)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              top: bombTopPosition,
              child: Center(
                child: Image.asset(
                  'assets/images/bomb.png',
                  width: bombSize,
                  height: bombSize,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            Consumer<ShopProvider>(
              builder: (context, shopProvider, child) {
                final moleImagePath = shopProvider.getMoleImagePath();
                final isOriginalMole =
                    moleImagePath.contains('33121063782.png');
                final adjustedSize =
                    isOriginalMole ? moleSize : moleSize * 0.60;
                final adjustedTopPosition = isOriginalMole
                    ? moleTopPosition
                    : moleTopPosition + skinPositionOffset;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  top: adjustedTopPosition,
                  child: Center(
                    child: Image.asset(
                      moleImagePath,
                      width: adjustedSize,
                      height: adjustedSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
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
                onTap: () {
                  if (shopProvider.usePowerUp('extra_time')) {
                    gp.usePowerUp(0);
                  }
                },
              ),
              _buildPowerUpButton(
                emoji: '✨',
                label: 'Double Pts',
                count: shopProvider.getPowerUpCount('double_points'),
                isActive: gp.gameState.isPowerUpActive(1),
                onTap: () {
                  if (shopProvider.usePowerUp('double_points')) {
                    gp.usePowerUp(1);
                  }
                },
              ),
              _buildPowerUpButton(
                emoji: '🐌',
                label: 'Slow Mole',
                count: shopProvider.getPowerUpCount('slow_mole'),
                isActive: gp.gameState.isPowerUpActive(2),
                onTap: () {
                  if (shopProvider.usePowerUp('slow_mole')) {
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
                Container(
                  width: 55,
                  height: 55,
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
                      style: const TextStyle(fontSize: 28),
                    ),
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
            const Text(
              'COMPLETE!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _scoreSubmitted = false;
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