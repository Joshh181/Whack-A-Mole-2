class AppConstants {
  // Game constants
  static const int gridRows = 4;
  static const int gridColumns = 3;
  static const int totalHoles = gridRows * gridColumns;
  
  // Timing constants (in milliseconds)
  static const int molePopUpDuration = 800;
  static const int moleStayDuration = 1200;
  static const int gameTimerSeconds = 50;
  
  // Scoring
  static const int pointsPerHit = 10;
  static const int doublePointsMultiplier = 2;
  
  // Power-ups
  static const int extraTimeSeconds = 10;
  static const double slowMoleSpeedMultiplier = 1.5;
  
  // Currency
  static const int startingCoins = 150;
  static const int dailyRewardCoins = 10;
  
  // Achievement thresholds
  static const int firstWhackThreshold = 10;
  static const int moleHunterThreshold = 50;
  static const int lightningFastThreshold = 100;
  static const int moleMasterThreshold = 200;
  
  // Shop item IDs
  static const String itemPartyHat = 'party_hat';
  static const String itemCrown = 'crown';
  static const String itemSunglasses = 'sunglasses';
  static const String itemExtraTime = 'extra_time';
  static const String itemDoublePoints = 'double_points';
  static const String itemSlowMole = 'slow_mole';
  static const String itemEyePatch = 'eye_patch';
  static const String itemRedScarf = 'red_scarf';
  static const String itemBowTie = 'bow_tie';
  
  // Storage keys
  static const String keyHighScore = 'high_score';
  static const String keyTotalScore = 'total_score';
  static const String keyCoins = 'coins';
  static const String keyUnlockedItems = 'unlocked_items';
  static const String keyEquippedItem = 'equipped_item';
  static const String keyDailyRewardsStreak = 'daily_rewards_streak';
  static const String keyLastLoginDate = 'last_login_date';
  static const String keySoundEffects = 'sound_effects';
  static const String keyBackgroundMusic = 'background_music';

  static const String keyLanguage = 'language';
  static const String keyHapticFeedback = 'haptic_feedback';
  static const String keyLevelsData = 'levels_data';
  static const String keyCurrentLevel = 'current_level';

  
}