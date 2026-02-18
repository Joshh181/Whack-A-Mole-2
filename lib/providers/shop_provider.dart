import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../models/daily_reward.dart';
import '../services/storage_service.dart';

class ShopProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  
  List<ShopItem> _items = [];
  List<DailyReward> _dailyRewards = [];
  int _coins = 150;
  String? _equippedSkin; // Changed from _equippedItem to _equippedSkin
  int _currentStreak = 0;
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
  String? get equippedItem => _equippedSkin; // For backward compatibility
  String? get equippedSkin => _equippedSkin;

  ShopProvider() {
    _initializeShop();
    _initializeDailyRewards();
  }

  void _initializeShop() {
    _items = [
      // ═══ MOLE SKINS ═══
      ShopItem(
        id: 'skin_cowboy',
        name: 'Cowboy Mole',
        price: 100,
        iconEmoji: '🤠',
        imagePath: 'assets/images/cowboy.png',
        type: ShopItemType.customization,
        description: 'Yeehaw partner!',
      ),
      ShopItem(
        id: 'skin_wizard',
        name: 'Wizard Mole',
        price: 150,
        iconEmoji: '🧙',
        imagePath: 'assets/images/wizard.png',
        type: ShopItemType.customization,
        description: 'Magical mole!',
      ),
      ShopItem(
        id: 'skin_pirate',
        name: 'Pirate Mole',
        price: 125,
        iconEmoji: '🏴‍☠️',
        imagePath: 'assets/images/pirate.png',
        type: ShopItemType.customization,
        description: 'Ahoy matey!',
      ),
      ShopItem(
        id: 'skin_ninja',
        name: 'Ninja Mole',
        price: 175,
        iconEmoji: '🥷',
        imagePath: 'assets/images/ninja.png',
        type: ShopItemType.customization,
        description: 'Silent and deadly!',
      ),
      
      // ═══ POWER-UPS ═══
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
    
    _equippedSkin = await _storage.getEquippedItem();
    _powerUpQuantities = await _storage.getPowerUpQuantities();
    
    notifyListeners();
  }

  Future<void> _loadDailyRewardsData() async {
    _currentStreak = await _storage.getDailyStreak();
    
    String? lastClaimString = await _storage.getLastClaimDate();
    if (lastClaimString != null && lastClaimString.isNotEmpty) {
      try {
        _lastClaimDate = DateTime.parse(lastClaimString);
        
        final now = DateTime.now();
        final difference = now.difference(_lastClaimDate!);
        
        if (difference.inHours > 48) {
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
    
    if (_equippedSkin != null) {
      await _storage.saveEquippedItem(_equippedSkin!);
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
    _equippedSkin = itemId;
    _saveShopData();
    notifyListeners();
  }
  
  void equipSkin(String skinId) {
    _equippedSkin = skinId;
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
  
  List<ShopItem> getSkinItems() {
    return _items.where((item) => 
      item.type == ShopItemType.customization && 
      item.id.startsWith('skin_')
    ).toList();
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

  // Get the image path for currently equipped skin, or default mole
  String getMoleImagePath() {
    if (_equippedSkin == null || _equippedSkin!.isEmpty) {
      return 'assets/images/33121063782.png'; // Default mole
    }
    
    final skin = _items.firstWhere(
      (item) => item.id == _equippedSkin,
      orElse: () => _items.first,
    );
    
    return skin.imagePath ?? 'assets/images/33121063782.png';
  }

  // ─── Daily Rewards ───────────────────────────────────────────────────────────

  bool canClaimDailyReward() {
    if (_lastClaimDate == null) return true;
    final diff = DateTime.now().difference(_lastClaimDate!);
    return diff.inHours >= 24;
  }

  int get nextDayToClaim {
    int next = (_currentStreak % 7) + 1;
    return next;
  }

  Future<bool> claimDailyReward(int day) async {
    if (!canClaimDailyReward()) return false;
    if (day != nextDayToClaim) return false;

    final reward = _dailyRewards[day - 1];
    if (reward.isClaimed) return false;

    addCoins(reward.coins);

    reward.isClaimed = true;
    await _storage.saveDailyRewardClaimed(day, true);

    _currentStreak++;
    await _storage.saveDailyStreak(_currentStreak);

    _lastClaimDate = DateTime.now();
    await _storage.saveLastClaimDate(_lastClaimDate!.toIso8601String());

    if (_currentStreak % 7 == 0) {
      for (var r in _dailyRewards) {
        r.isClaimed = false;
        await _storage.saveDailyRewardClaimed(r.day, false);
      }
    }

    notifyListeners();
    return true;
  }
}