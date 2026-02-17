import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import 'dart:async';

class DailyRewardsScreen extends StatefulWidget {
  const DailyRewardsScreen({super.key});

  @override
  State<DailyRewardsScreen> createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    // Refresh every second to check if 24 hours have passed
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00D9FF), Color(0xFFFFB6C1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Daily Rewards',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Status display (no countdown, just ready or not ready)
              Consumer<ShopProvider>(
                builder: (context, shopProvider, child) {
                  final canClaim = shopProvider.canClaimDailyReward();
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: canClaim ? Colors.green.shade400 : Colors.orange.shade300,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canClaim ? Icons.card_giftcard : Icons.schedule,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          canClaim ? 'Ready to Claim!' : 'Come Back in 24 Hours',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Login every day to claim amazing rewards!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              Expanded(
                child: Consumer<ShopProvider>(
                  builder: (context, shopProvider, child) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: shopProvider.dailyRewards.length,
                      itemBuilder: (context, index) {
                        final reward = shopProvider.dailyRewards[index];
                        final isToday = index == shopProvider.currentStreak;
                        final canClaim = shopProvider.canClaimDailyReward() && isToday;
                        
                        return GestureDetector(
                          onTap: canClaim && !reward.isClaimed
                              ? () {
                                  shopProvider.claimDailyReward(reward.day);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🎉 Claimed ${reward.coins} coins! Come back in 24 hours.'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: canClaim
                                    ? [Colors.yellow, Colors.orange]
                                    : reward.isClaimed
                                        ? [Colors.blue.shade200, Colors.purple.shade200]
                                        : [Colors.white, Colors.white],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: canClaim
                                  ? Border.all(color: Colors.amber, width: 3)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Day ${reward.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: canClaim || reward.isClaimed ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                reward.isClaimed
                                    ? const Icon(Icons.check_circle, color: Colors.white, size: 50)
                                    : Text(reward.iconEmoji, style: const TextStyle(fontSize: 50)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🪙', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${reward.coins}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: canClaim || reward.isClaimed ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reward.isClaimed
                                      ? 'CLAIMED'
                                      : canClaim
                                          ? 'TAP TO CLAIM!'
                                          : isToday
                                              ? 'WAITING...'
                                              : 'LOCKED',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: canClaim || reward.isClaimed ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}