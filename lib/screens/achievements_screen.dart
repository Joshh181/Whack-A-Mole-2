import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── BACKGROUND ─────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF512DA8), // Deep Purple
                  Color(0xFF880E4F), // Deep Pink/Wine
                  Color(0xFF311B92), // Very Deep Purple
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // ─── CUSTOM TOP BAR ──────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      _PremiumBackButton(onPressed: () => Navigator.pop(context)),
                      const Spacer(),
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'ACHIEVEMENTS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balancing back button
                    ],
                  ),
                ),
                
                // ─── ACHIEVEMENTS LIST ───────────────────────
                Expanded(
                  child: Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: gameProvider.achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = gameProvider.achievements[index];
                          final isCompleted = achievement.progressPercentage >= 100;
                          
                          return _AchievementCard(
                            achievement: achievement,
                            isCompleted: isCompleted,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACHIEVEMENT CARD WIDGET ─────────────────────────
class _AchievementCard extends StatelessWidget {
  final dynamic achievement; // Using dynamic because achievement model was shown in view_file
  final bool isCompleted;

  const _AchievementCard({
    required this.achievement,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.amber.withOpacity(0.1) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted ? Colors.amber.withOpacity(0.4) : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ICON
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              boxShadow: isCompleted ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: Center(
              child: Text(
                achievement.iconEmoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? Colors.amber : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // PROGRESS BAR
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (achievement.progressPercentage / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted 
                              ? [Colors.amber, Colors.orange]
                              : [const Color(0xFF00E676), const Color(0xFF00C853)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: (isCompleted ? Colors.amber : const Color(0xFF00E676)).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${achievement.currentProgress} / ${achievement.threshold}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${achievement.progressPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isCompleted ? Colors.amber : Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE BACK BUTTON ───────────────────────────
class _PremiumBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PremiumBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}