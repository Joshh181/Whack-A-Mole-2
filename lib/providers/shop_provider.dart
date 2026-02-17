import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../models/daily_reward.dart';
import '../services/storage_service.dart';

class ShopProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  
  List<ShopItem> _items = [];
  List<DailyReward> _dailyRewards = [];
  int _coins = 150;
  String? _equippedItem;
  int _currentStreak = 0; // 0 = none claimed yet, 1 = day1 claimed, etc.
  DateTime? _lastClaimDate;
  
  Map<String, int> _powerUpQuantities = {
    'extra_time': 0,
    'double_points': 0,
    'slow_mole': 0,
  };

  // Public getters
  List<ShopItem> get items => _items;
  List<ShopItem> get shopItems => _items;
  List<DailyReward> get dailyRewards => _dailyRewards;
  int get coins => _coins;
  int get currentStreak => _currentStreak;
  String? get equippedItem => _equippedItem;

  ShopProvider() {
    _initializeShop();
    _initializeDailyRewards();
  }

  void _initializeShop() {
    _items = [
      ShopItem(
        id: 'party_hat',
        name: 'Party Hat',
        price: 50,
        iconEmoji: '🎩',
        type: ShopItemType.customization,
      ),
      ShopItem(
        id: 'crown',
        name: 'Crown',
        price: 100,
        iconEmoji: '👑',
        type: ShopItemType.customization,
      ),
      ShopItem(
        id: 'sunglasses',
        name: 'Sunglasses',
        price: 75,
        iconEmoji: '🕶️',
        type: ShopItemType.customization,
      ),
      ShopItem(
        id: 'extra_time',
        name: 'Extra Time',
        price: 30,
        iconEmoji: '⏰',
        type: ShopItemType.powerUp,
        description: '+10 seconds',
      ),
      ShopItem(
        id: 'double_points',
        name: 'Double Points',
        price: 40,
        iconEmoji: '✨',
        type: ShopItemType.powerUp,
        description: '2x points for 10s',
      ),
      ShopItem(
        id: 'slow_mole',
        name: 'Slow Mole',
        price: 50,
        iconEmoji: '🐌',
        type: ShopItemType.powerUp,
        description: 'Slower moles for 10s',
      ),
    ];
    
    _loadShopData();
  }

  void _initializeDailyRewards() {
    _dailyRewards = [
      DailyReward(day: 1, coins: 50,  iconEmoji: '🪙'),
      DailyReward(day: 2, coins: 75,  iconEmoji: '🪙'),
      DailyReward(day: 3, coins: 100, iconEmoji: '🪙'),
      DailyReward(day: 4, coins: 150, iconEmoji: '🪙'),
      DailyReward(day: 5, coins: 200, iconEmoji: '🪙'),
      DailyReward(day: 6, coins: 250, iconEmoji: '🪙'),
      DailyReward(day: 7, coins: 500, iconEmoji: '🪙'),
    ];
    _loadDailyRewardsData();
  }

  Future<void> _loadShopData() async {
    _coins = await _storage.getCoins();
    
    List<String> unlockedIds = await _storage.getUnlockedItems();
    for (var item in _items) {
      if (unlockedIds.contains(item.id)) {
        item.isUnlocked = true;
      }
    }
    
    _equippedItem = await _storage.getEquippedItem();
    _powerUpQuantities = await _storage.getPowerUpQuantities();
    
    notifyListeners();
  }

  Future<void> _loadDailyRewardsData() async {
    _currentStreak = await _storage.getDailyStreak();
    
    String? lastClaimString = await _storage.getLastClaimDate();
    if (lastClaimString != null && lastClaimString.isNotEmpty) {
      try {
        _lastClaimDate = DateTime.parse(lastClaimString);
        
        // Check if streak should be reset (more than 48 hours since last claim)
        final now = DateTime.now();
        final difference = now.difference(_lastClaimDate!);
        
        if (difference.inHours > 48) {
          // Streak broken - reset everything back to day 1
          _currentStreak = 0;
          _lastClaimDate = null;
          await _storage.saveDailyStreak(0);
          await _storage.saveLastClaimDate('');
          
          for (var r in _dailyRewards) {
            r.isClaimed = false;
            await _storage.saveDailyRewardClaimed(r.day, false);
          }
        }
      } catch (e) {
        _currentStreak = 0;
        _lastClaimDate = null;
      }
    }
    
    // Load claimed status for each day
    for (var reward in _dailyRewards) {
      reward.isClaimed = await _storage.getDailyRewardClaimed(reward.day);
    }
    
    notifyListeners();
  }

  Future<void> _saveShopData() async {
    await _storage.saveCoins(_coins);
    
    List<String> unlockedIds = _items
        .where((item) => item.isUnlocked)
        .map((item) => item.id)
        .toList();
    await _storage.saveUnlockedItems(unlockedIds);
    
    if (_equippedItem != null) {
      await _storage.saveEquippedItem(_equippedItem!);
    }
    
    await _storage.savePowerUpQuantities(_powerUpQuantities);
  }

  bool purchaseItem(String itemId) {
    final item = _items.firstWhere((i) => i.id == itemId);
    
    if (_coins >= item.price) {
      _coins -= item.price;
      
      if (item.type == ShopItemType.customization) {
        item.isUnlocked = true;
      } else {
        _powerUpQuantities[itemId] = (_powerUpQuantities[itemId] ?? 0) + 1;
      }
      
      _saveShopData();
      notifyListeners();
      return true;
    }
    return false;
  }

  void equipItem(String itemId) {
    _equippedItem = itemId;
    _saveShopData();
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveShopData();
    notifyListeners();
  }

  List<ShopItem> getCustomizationItems() {
    return _items.where((item) => item.type == ShopItemType.customization).toList();
  }

  List<ShopItem> getPowerUpItems() {
    return _items.where((item) => item.type == ShopItemType.powerUp).toList();
  }

  int getPowerUpCount(String powerUpId) {
    return _powerUpQuantities[powerUpId] ?? 0;
  }

  bool usePowerUp(String powerUpId) {
    int count = _powerUpQuantities[powerUpId] ?? 0;
    if (count > 0) {
      _powerUpQuantities[powerUpId] = count - 1;
      _saveShopData();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── Daily Rewards ───────────────────────────────────────────────────────────

  /// Returns true if 24 hours have passed since last claim (or never claimed)
  bool canClaimDailyReward() {
    if (_lastClaimDate == null) return true;
    final diff = DateTime.now().difference(_lastClaimDate!);
    return diff.inHours >= 24;
  }

  /// The next day the player should claim (1-based). 
  /// After day 7 it wraps back to 1.
  int get nextDayToClaim {
    // _currentStreak is how many days have been claimed so far.
    // So the NEXT day is _currentStreak + 1, wrapped to 1-7.
    int next = (_currentStreak % 7) + 1;
    return next;
  }

  /// Claim today's reward. `day` must equal nextDayToClaim.
  Future<bool> claimDailyReward(int day) async {
    // Guard: must be the correct next day and 24h must have passed
    if (!canClaimDailyReward()) return false;
    if (day != nextDayToClaim) return false;

    final reward = _dailyRewards[day - 1]; // list is 0-indexed
    if (reward.isClaimed) return false;

    // Give coins
    addCoins(reward.coins);

    // Mark this day as claimed in memory + storage
    reward.isClaimed = true;
    await _storage.saveDailyRewardClaimed(day, true);

    // Advance streak counter
    _currentStreak++;
    await _storage.saveDailyStreak(_currentStreak);

    // Record when we claimed
    _lastClaimDate = DateTime.now();
    await _storage.saveLastClaimDate(_lastClaimDate!.toIso8601String());

    // After day 7 completed, reset so the whole cycle can start again
    if (_currentStreak % 7 == 0) {
      // Keep _currentStreak as-is (it's a multiple of 7 now) so nextDayToClaim
      // wraps back to day 1, but clear all isClaimed flags for the new cycle.
      for (var r in _dailyRewards) {
        r.isClaimed = false;
        await _storage.saveDailyRewardClaimed(r.day, false);
      }
    }

    notifyListeners();
    return true;
  }
}