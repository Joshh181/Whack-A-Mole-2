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
              Color(0xFF32CD32),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              // Title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'SELECT LEVEL',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Main Panel with levels
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Consumer<LevelProvider>(
                    builder: (context, levelProvider, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First row - Levels 1-2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLevelButton(
                                context,
                                levelProvider.levels[0],
                                levelProvider,
                              ),
                              const SizedBox(width: 20),
                              _buildLevelButton(
                                context,
                                levelProvider.levels[1],
                                levelProvider,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Second row - Levels 3-4
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLevelButton(
                                context,
                                levelProvider.levels[2],
                                levelProvider,
                              ),
                              const SizedBox(width: 20),
                              _buildLevelButton(
                                context,
                                levelProvider.levels[3],
                                levelProvider,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Third row - Level 5 centered
                          _buildLevelButton(
                            context,
                            levelProvider.levels[4],
                            levelProvider,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Home Button
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.white, width: 4),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'HOME',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
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

  Widget _buildLevelButton(BuildContext context, Level level, LevelProvider levelProvider) {
    return GestureDetector(
      onTap: () {
        if (level.isUnlocked) {
          _showLevelDialog(context, level, levelProvider);
        }
      },
      child: Container(
        width: 100,
        height: 130,
        decoration: BoxDecoration(
          color: level.isUnlocked 
              ? const Color(0xFFDEB887)
              : const Color(0xFF9E8B7E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: level.isUnlocked 
                ? const Color(0xFF8B6914) 
                : const Color(0xFF5D4E37),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Level number or lock icon
            if (level.isUnlocked)
              Text(
                '${level.levelNumber}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF654321),
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              )
            else
              const Icon(
                Icons.lock,
                size: 56,
                color: Color(0xFF3E2723),
              ),
            
            const SizedBox(height: 8),
            
            // Stars display
            if (level.isUnlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < level.stars ? Icons.star : Icons.star_border,
                    color: index < level.stars 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFF8B6914),
                    size: 18,
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  void _showLevelDialog(BuildContext context, Level level, LevelProvider levelProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF8BC34A), width: 5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Level number
                Text(
                  'LEVEL ${level.levelNumber}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF654321),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Star requirements
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Star Requirements:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('⭐ 50 points', style: TextStyle(fontSize: 14)),
                      Text('⭐⭐ 70 points', style: TextStyle(fontSize: 14)),
                      Text('⭐⭐⭐ 100 points', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // High score
                if (level.highScore > 0)
                  Text(
                    'Best: ${level.highScore} points',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                
                const SizedBox(height: 25),
                
                // Play button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    levelProvider.setCurrentLevel(level.levelNumber);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(level: level),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Colors.white, width: 3),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
}