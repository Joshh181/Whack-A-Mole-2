import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  final String userId;
  final String username;
  final int highScore;
  final int totalScore;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.highScore,
    required this.totalScore,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntry(
      userId: json['user_id'].toString(),
      username: json['username'] ?? 'Anonymous',
      highScore: json['high_score'] ?? 0,
      totalScore: json['total_score'] ?? 0,
      rank: rank,
    );
  }
}

class LeaderboardProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<LeaderboardEntry> _globalLeaderboard = [];
  LeaderboardEntry? _currentUserEntry;
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── FETCH LEADERBOARD ────────────────────────────────────────
  Future<void> fetchLeaderboard({int limit = 100}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Fetching leaderboard...');

      final List<dynamic> response = await _supabase
          .from('leaderboard')
          .select('*')
          .order('high_score', ascending: false)
          .limit(limit);

      debugPrint('Leaderboard response count: ${response.length}');
      debugPrint('Leaderboard data: $response');

      _globalLeaderboard = [];
      for (int i = 0; i < response.length; i++) {
        _globalLeaderboard.add(
          LeaderboardEntry.fromJson(response[i], i + 1),
        );
      }

      // Find current user in the list
      final String? currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        for (final LeaderboardEntry entry in _globalLeaderboard) {
          if (entry.userId == currentUserId) {
            _currentUserEntry = entry;
            break;
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load leaderboard: $e';
      debugPrint('ERROR fetching leaderboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── SUBMIT SCORE ─────────────────────────────────────────────
  Future<bool> submitScore({
    required String userId,
    required String username,
    required int score,
  }) async {
    try {
      debugPrint('=== submitScore() called ===');
      debugPrint('userId: $userId');
      debugPrint('username: $username');
      debugPrint('score: $score');

      // Check if user already has an entry
      final List<dynamic> existing = await _supabase
          .from('leaderboard')
          .select('*')
          .eq('user_id', userId);

      debugPrint('Existing entries found: ${existing.length}');

      if (existing.isNotEmpty) {
        // User already exists — UPDATE
        final Map<String, dynamic> current = existing[0];
        final int currentHighScore = current['high_score'] ?? 0;
        final int currentTotalScore = current['total_score'] ?? 0;

        debugPrint('Current high score: $currentHighScore');

        final Map<String, dynamic> updateData = {
          'total_score': currentTotalScore + score,
          'last_played': DateTime.now().toIso8601String(),
        };

        // Only update high_score if new score is higher
        if (score > currentHighScore) {
          updateData['high_score'] = score;
          debugPrint('New high score!');
        }

        await _supabase
            .from('leaderboard')
            .update(updateData)
            .eq('user_id', userId);

        debugPrint('Score updated successfully');
      } else {
        // User does not exist — INSERT
        debugPrint('Inserting new leaderboard entry...');

        await _supabase.from('leaderboard').insert({
          'user_id': userId,
          'username': username,
          'high_score': score,
          'total_score': score,
          'last_played': DateTime.now().toIso8601String(),
        });

        debugPrint('New entry inserted successfully');
      }

      // Refresh leaderboard after submit
      await fetchLeaderboard();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit score: $e';
      debugPrint('ERROR submitting score: $e');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}