import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaderboardProvider>(context, listen: false).fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

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
                  Color(0xFF0F2027), // Deep Charcoal
                  Color(0xFF203A43), // Deep Sea
                  Color(0xFF2C5364), // Dark Slate
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
                      const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'HALL OF FAME',
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
                
                // ─── LEADERBOARD LIST ────────────────────────
                Expanded(
                  child: leaderboardProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                      : leaderboardProvider.errorMessage != null
                          ? _buildErrorState(leaderboardProvider)
                          : leaderboardProvider.globalLeaderboard.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  color: Colors.amber,
                                  backgroundColor: const Color(0xFF203A43),
                                  onRefresh: () => leaderboardProvider.fetchLeaderboard(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    itemCount: leaderboardProvider.globalLeaderboard.length,
                                    itemBuilder: (context, index) {
                                      final entry = leaderboardProvider.globalLeaderboard[index];
                                      final isCurrentUser = entry.userId == authProvider.currentUser?.id;
                                      
                                      return _LeaderboardItem(
                                        entry: entry,
                                        isCurrentUser: isCurrentUser,
                                      );
                                    },
                                  ),
                                ),
                ),
                
                // ─── CURRENT USER STATS (Fixed Bottom) ───────
                if (leaderboardProvider.currentUserEntry != null)
                  _CurrentUserRankCard(
                    entry: leaderboardProvider.currentUserEntry!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'NO CHAMPIONS YET',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(LeaderboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.fetchLeaderboard(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('RETRY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LEADERBOARD LIST ITEM ──────────────────────────
class _LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardItem({
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.amber.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentUser ? Colors.amber.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // RANK BADGE
          _RankBadge(rank: entry.rank),
          const SizedBox(width: 16),
          
          // USERNAME
          Expanded(
            child: Text(
              entry.username.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.bold,
                color: isCurrentUser ? Colors.amber : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // SCORE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.highScore}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'POINTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── RANK BADGE WIDGET ──────────────────────────────
class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank <= 3) {
      final colors = [
        [const Color(0xFFFFD700), const Color(0xFFFFA000)], // Gold
        [const Color(0xFFC0C0C0), const Color(0xFF8E8E8E)], // Silver
        [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
      ];
      
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors[rank - 1]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[rank - 1].first.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── CURRENT USER RANK CARD ────────────────────────
class _CurrentUserRankCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _CurrentUserRankCard({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6200EA), Color(0xFF311B92)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'YOUR CURRENT RANK',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('🏆 ', style: TextStyle(fontSize: 20)),
                  Text(
                    '#${entry.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.highScore.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                'HIGH SCORE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
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