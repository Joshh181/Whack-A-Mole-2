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
                        itemCount: levelProvider.levels.length,
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
    // Vibrant colors for the card background
    if (level.levelNumber <= 5) return const Color(0xFF66BB6A); // Green
    if (level.levelNumber <= 8) return const Color(0xFFFFA726); // Orange
    return const Color(0xFFEF5350); // Red
  }

  Color _getDarkColor() {
    // Darker shade for the 3D depth and text
    if (level.levelNumber <= 5) return const Color(0xFF2E7D32);
    if (level.levelNumber <= 8) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  String _getDifficultyLabel() {
    if (level.levelNumber <= 5) return 'EASY';
    if (level.levelNumber <= 8) return 'MEDIUM';
    return 'HARD';
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !level.isUnlocked;
    final cardColor = isLocked ? Colors.grey.shade400 : _getLevelColor();
    final darkColor = isLocked ? Colors.grey.shade600 : _getDarkColor();

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // 3D bottom depth
            BoxShadow(
              color: darkColor.withOpacity(0.8),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
            // Soft drop shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 12),
              blurRadius: 15,
            ),
          ],
          border: Border.all(
            color: isLocked ? Colors.grey.shade300 : Colors.white.withOpacity(0.9),
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // Glassy top highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: Avatar (Level Number) and High Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Level Number Badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${level.levelNumber}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isLocked ? Colors.grey : darkColor,
                            ),
                          ),
                        ),
                      ),
                      
                      // Trophy High Score Pill
                      if (!isLocked && level.highScore > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300), // Amber 600
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.shade200, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFE65100), // Orange 900
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Icon(Icons.emoji_events_rounded, size: 14, color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${level.highScore}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 2)
                                  ]
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Middle Area: Stars or Lock Icon
                  Expanded(
                    child: Center(
                      child: isLocked
                        ? const Icon(
                            Icons.lock_rounded, 
                            size: 48, 
                            color: Colors.white54,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final earned = index < level.stars;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  earned ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: earned ? const Color(0xFFFFD54F) : Colors.white60,
                                  size: 32,
                                  shadows: earned ? const [
                                    Shadow(color: Color(0xFFF57F17), offset: Offset(0, 3), blurRadius: 4)
                                  ] : null,
                                ),
                              );
                            }),
                          ),
                    ),
                  ),

                  // Bottom Area: Difficulty Tag
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Text(
                        _getDifficultyLabel(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    
                  if (isLocked)
                    const SizedBox(height: 28), // Placeholder for vertical balance when locked
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}