import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../models/level.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF98D8C8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ═══ HEADER ═══
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.9)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFF00E676), width: 3),
                  ),
                  child: const Text(
                    'SELECT LEVEL',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00897B),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // ═══ LEVELS GRID ═══
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFFDE7).withOpacity(0.95),
                        const Color(0xFFF0F4C3).withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Consumer<LevelProvider>(
                    builder: (context, levelProvider, child) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: levelProvider.levels.length, // Now 10 levels
                        itemBuilder: (context, index) {
                          final level = levelProvider.levels[index];
                          return _LevelCard(level: level);
                        },
                      );
                    },
                  ),
                ),
              ),

              // ═══ HOME BUTTON ═══
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_rounded, size: 28, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'HOME',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _LevelCard extends StatelessWidget {
  final Level level;

  const _LevelCard({required this.level});

  Color _getLevelColor() {
    // Levels 1-5: Green shades
    if (level.levelNumber <= 5) {
      return Colors.green.shade400;
    }
    // Levels 6-8: Orange shades
    if (level.levelNumber <= 8) {
      return Colors.orange.shade400;
    }
    // Levels 9-10: Red shades
    return Colors.red.shade400;
  }

  String _getLevelBadge() {
    if (level.levelNumber <= 5) return '🟢';  // Beginner
    if (level.levelNumber <= 8) return '🟠';  // Intermediate
    return '🔴';  // Expert
  }

  String _getDifficultyLabel() {
    if (level.levelNumber <= 5) return 'EASY';
    if (level.levelNumber <= 8) return 'MEDIUM';
    return 'HARD';
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !level.isUnlocked;
    final cardColor = _getLevelColor();

    return GestureDetector(
      onTap: () {
        if (level.isUnlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(level: level),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Complete Level ${level.levelNumber - 1} to unlock!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [cardColor, cardColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isLocked 
                  ? Colors.grey.withOpacity(0.3)
                  : cardColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isLocked ? Colors.grey.shade300 : Colors.white,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // Level content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Level number + badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${level.levelNumber}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isLocked ? Colors.grey : cardColor,
                          ),
                        ),
                      ),
                      if (!isLocked)
                        Text(
                          _getLevelBadge(),
                          style: const TextStyle(fontSize: 28),
                        ),
                    ],
                  ),

                  // Grid info removed

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Icon(
                        index < level.stars ? Icons.star : Icons.star_border,
                        color: index < level.stars 
                            ? Colors.amber 
                            : (isLocked ? Colors.white54 : Colors.white70),
                        size: 24,
                      );
                    }),
                  ),

                  // Difficulty label
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: cardColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Lock icon
            if (isLocked)
              const Center(
                child: Icon(
                  Icons.lock,
                  size: 50,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}