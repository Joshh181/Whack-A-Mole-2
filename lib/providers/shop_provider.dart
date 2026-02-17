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
  int _currentStreak = 0;
  DateTime? _lastClaimDate;
  
  Map<String, int> _powerUpQuantities = {
    'extra_time': 0,
    'double_points': 0,
    'slow_mole': 0,
  };

  // Public getters
  List<ShopItem> get items => _items;
  List<ShopItem> get shopItems => _items;  // Alias for compatibility
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
      DailyReward(day: 1, coins: 50, iconEmoji: '🪙'),
      DailyReward(day: 2, coins: 75, iconEmoji: '🪙'),
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
        
        // Check if streak should be reset (more than 48 hours)
        final now = DateTime.now();
        final difference = now.difference(_lastClaimDate!);
        
        if (difference.inHours > 48) {
          // Streak broken, reset everything
          _currentStreak = 0;
          _lastClaimDate = null;
          await _storage.saveDailyStreak(0);
          await _storage.saveLastClaimDate('');
          
          // Reset all claimed statuses
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
  
  // Daily Rewards Methods
  bool canClaimDailyReward() {
    if (_lastClaimDate == null) {
      return true; // First time claiming
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastClaimDate!);
    
    // Can claim if 24 hours have passed
    return difference.inHours >= 24;
  }
  
  DateTime? get nextClaimTime {
    if (_lastClaimDate == null) {
      return null; // Can claim now
    }
    
    final nextClaim = _lastClaimDate!.add(const Duration(hours: 24));
    final now = DateTime.now();
    
    if (now.isAfter(nextClaim)) {
      return null; // Can claim now
    }
    
    return nextClaim;
  }
  
  // Method for claiming daily rewards
  Future<void> claimDailyReward(int day) async {
    if (!canClaimDailyReward()) {
      return; // Cannot claim yet
    }
    
    if (day == _currentStreak + 1 && day <= _dailyRewards.length) {
      final reward = _dailyRewards[day - 1];
      
      if (!reward.isClaimed) {
        // Add coins
        addCoins(reward.coins);
        
        // Mark as claimed
        reward.isClaimed = true;
        await _storage.saveDailyRewardClaimed(day, true);
        
        // Update streak
        _currentStreak = day;
        await _storage.saveDailyStreak(_currentStreak);
        
        // Update last claim date
        _lastClaimDate = DateTime.now();
        await _storage.saveLastClaimDate(_lastClaimDate!.toIso8601String());
        
        // Reset streak if it was day 7
        if (day == 7) {
          _currentStreak = 0;
          await _storage.saveDailyStreak(0);
          
          // Reset all claimed statuses
          for (var r in _dailyRewards) {
            r.isClaimed = false;
            await _storage.saveDailyRewardClaimed(r.day, false);
          }
        }
        
        notifyListeners();
      }
    }
  }
}