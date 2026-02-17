import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00E676), Color(0xFF00BCD4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                      'CUSTOMIZE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Character preview
              Consumer<ShopProvider>(
                builder: (context, shopProvider, child) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Mole image
                        Image.asset(
                          'assets/images/MOLE.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        // Equipped item overlay
                        if (shopProvider.equippedItem != null)
                          Positioned(
                            top: 0,
                            child: Text(
                              _getItemEmoji(shopProvider.equippedItem!),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              // Items grid
              Expanded(
                child: Consumer<ShopProvider>(
                  builder: (context, shopProvider, child) {
                    final items = shopProvider.getCustomizationItems();
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isEquipped = shopProvider.equippedItem == item.id;
                        return GestureDetector(
                          onTap: item.isUnlocked
                              ? () {
                                  if (isEquipped) {
                                    shopProvider.equipItem('');
                                  } else {
                                    shopProvider.equipItem(item.id);
                                  }
                                }
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isEquipped ? Colors.green : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: item.isUnlocked
                                        ? Colors.purple.shade100
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: item.isUnlocked
                                        ? Text(item.iconEmoji, style: const TextStyle(fontSize: 50))
                                        : const Icon(Icons.lock, size: 40, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.isUnlocked
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.isUnlocked ? (isEquipped ? 'EQUIPPED' : 'OWNED') : 'LOCKED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: item.isUnlocked ? Colors.black : Colors.white,
                                    ),
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

  String _getItemEmoji(String itemId) {
    const itemEmojis = {
      'party_hat': '🎩',
      'crown': '👑',
      'sunglasses': '🕶️',
      'eye_patch': '🏴‍☠️',
      'red_scarf': '🧣',
      'bow_tie': '🎀',
    };
    return itemEmojis[itemId] ?? '';
  }
}