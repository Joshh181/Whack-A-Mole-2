import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============ COINS ============
  Future<int> getCoins() async {
    final p = await prefs;
    return p.getInt('coins') ?? 150;
  }

  Future<void> saveCoins(int coins) async {
    final p = await prefs;
    await p.setInt('coins', coins);
  }

  // ============ UNLOCKED ITEMS ============
  Future<List<String>> getUnlockedItems() async {
    final p = await prefs;
    return p.getStringList('unlocked_items') ?? [];
  }

  Future<void> saveUnlockedItems(List<String> items) async {
    final p = await prefs;
    await p.setStringList('unlocked_items', items);
  }

  // ============ EQUIPPED ITEM ============
  Future<String?> getEquippedItem() async {
    final p = await prefs;
    return p.getString('equipped_item');
  }

  Future<void> saveEquippedItem(String itemId) async {
    final p = await prefs;
    await p.setString('equipped_item', itemId);
  }

  // ============ POWER-UP QUANTITIES ============
  Future<Map<String, int>> getPowerUpQuantities() async {
    final p = await prefs;
    String? json = p.getString('powerup_quantities');
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
    await p.setString('powerup_quantities', json);
  }

  // ============ DAILY REWARDS ============
  Future<int> getDailyStreak() async {
    final p = await prefs;
    return p.getInt('daily_streak') ?? 0;
  }

  Future<void> saveDailyStreak(int streak) async {
    final p = await prefs;
    await p.setInt('daily_streak', streak);
  }

  Future<String?> getLastClaimDate() async {
    final p = await prefs;
    return p.getString('last_claim_date');
  }

  Future<void> saveLastClaimDate(String date) async {
    final p = await prefs;
    await p.setString('last_claim_date', date);
  }

  Future<bool> getDailyRewardClaimed(int day) async {
    final p = await prefs;
    return p.getBool('daily_reward_day_$day') ?? false;
  }

  Future<void> saveDailyRewardClaimed(int day, bool claimed) async {
    final p = await prefs;
    await p.setBool('daily_reward_day_$day', claimed);
  }

  // ============ SETTINGS ============
  Future<bool> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key) ?? true;
  }

  Future<void> saveBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool(key, value);
  }

  Future<String> getString(String key) async {
    final p = await prefs;
    return p.getString(key) ?? 'English';
  }

  Future<void> saveString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  // ============ GENERIC METHODS ============
  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  Future<void> saveInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(key, value);
  }

  Future<bool> remove(String key) async {
    final p = await prefs;
    return await p.remove(key);
  }

  Future<bool> clear() async {
    final p = await prefs;
    return await p.clear();
  }
  Future<int> getHighScore() async {
  final p = await prefs;
  return p.getInt('high_score') ?? 0;
}

Future<void> saveHighScore(int score) async {
  final p = await prefs;
  await p.setInt('high_score', score);
}
}