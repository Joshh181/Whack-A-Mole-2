import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  String? _currentUserId;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // USER MANAGEMENT
  // ════════════════════════════════════════════════════════════════════════════

  /// Set the current user ID - call this after login
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Get the current user ID
  String? getUserId() {
    return _currentUserId;
  }

  /// Clear all data for the current user and reset user ID
  Future<void> clearUserData() async {
    if (_currentUserId == null) return;
    
    final p = await prefs;
    final allKeys = p.getKeys();
    
    // Remove all keys that belong to current user
    for (var key in allKeys) {
      if (key.startsWith('user_$_currentUserId')) {
        await p.remove(key);
      }
    }
    
    _currentUserId = null;
  }

  /// Generate user-specific key
  String _userKey(String key) {
    if (_currentUserId == null) {
      throw Exception('No user logged in! Call setUserId() first.');
    }
    return 'user_${_currentUserId}_$key';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // COINS
  // ════════════════════════════════════════════════════════════════════════════

  Future<int> getCoins() async {
    final p = await prefs;
    return p.getInt(_userKey('coins')) ?? 150; // New users start with 150
  }

  Future<void> saveCoins(int coins) async {
    final p = await prefs;
    await p.setInt(_userKey('coins'), coins);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UNLOCKED ITEMS
  // ════════════════════════════════════════════════════════════════════════════

  Future<List<String>> getUnlockedItems() async {
    final p = await prefs;
    return p.getStringList(_userKey('unlocked_items')) ?? [];
  }

  Future<void> saveUnlockedItems(List<String> items) async {
    final p = await prefs;
    await p.setStringList(_userKey('unlocked_items'), items);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EQUIPPED ITEM
  // ════════════════════════════════════════════════════════════════════════════

  Future<String?> getEquippedItem() async {
    final p = await prefs;
    return p.getString(_userKey('equipped_item'));
  }

  Future<void> saveEquippedItem(String itemId) async {
    final p = await prefs;
    await p.setString(_userKey('equipped_item'), itemId);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // POWER-UP QUANTITIES
  // ════════════════════════════════════════════════════════════════════════════

  Future<Map<String, int>> getPowerUpQuantities() async {
    final p = await prefs;
    String? json = p.getString(_userKey('powerup_quantities'));
    if (json != null) {
      Map<String, dynamic> decoded = jsonDecode(json);
      return decoded.map((key, value) => MapEntry(key, value as int));
    }
    return {
      'extra_time': 0,
      'double_points': 0,
      'slow_mole': 0,
    };
  }

  Future<void> savePowerUpQuantities(Map<String, int> quantities) async {
    final p = await prefs;
    String json = jsonEncode(quantities);
    await p.setString(_userKey('powerup_quantities'), json);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DAILY REWARDS
  // ════════════════════════════════════════════════════════════════════════════

  Future<int> getDailyStreak() async {
    final p = await prefs;
    return p.getInt(_userKey('daily_streak')) ?? 0;
  }

  Future<void> saveDailyStreak(int streak) async {
    final p = await prefs;
    await p.setInt(_userKey('daily_streak'), streak);
  }

  Future<String?> getLastClaimDate() async {
    final p = await prefs;
    return p.getString(_userKey('last_claim_date'));
  }

  Future<void> saveLastClaimDate(String date) async {
    final p = await prefs;
    await p.setString(_userKey('last_claim_date'), date);
  }

  Future<bool> getDailyRewardClaimed(int day) async {
    final p = await prefs;
    return p.getBool(_userKey('daily_reward_day_$day')) ?? false;
  }

  Future<void> saveDailyRewardClaimed(int day, bool claimed) async {
    final p = await prefs;
    await p.setBool(_userKey('daily_reward_day_$day'), claimed);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HIGH SCORE
  // ════════════════════════════════════════════════════════════════════════════

  Future<int> getHighScore() async {
    final p = await prefs;
    return p.getInt(_userKey('high_score')) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final p = await prefs;
    await p.setInt(_userKey('high_score'), score);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SETTINGS (GLOBAL - NOT USER-SPECIFIC)
  // ════════════════════════════════════════════════════════════════════════════

  Future<bool> getBool(String key) async {
    final p = await prefs;
    return p.getBool('global_$key') ?? true;
  }

  Future<void> saveBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool('global_$key', value);
  }

  Future<String> getString(String key) async {
    final p = await prefs;
    return p.getString('global_$key') ?? 'English';
  }

  Future<void> saveString(String key, String value) async {
    final p = await prefs;
    await p.setString('global_$key', value);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GENERIC METHODS
  // ════════════════════════════════════════════════════════════════════════════

  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(_userKey(key));
  }

  Future<void> saveInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(_userKey(key), value);
  }

  Future<bool> remove(String key) async {
    final p = await prefs;
    return await p.remove(_userKey(key));
  }

  Future<bool> clear() async {
    final p = await prefs;
    return await p.clear();
  }
}