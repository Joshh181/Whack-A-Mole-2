class DailyReward {
  final int day;
  final int coins;
  final String iconEmoji;
  bool isClaimed;

  DailyReward({
    required this.day,
    required this.coins,
    required this.iconEmoji,
    this.isClaimed = false,
  });
}