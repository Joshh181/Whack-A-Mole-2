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
                      'CUSTOMIZE MOLE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mole preview with equipped skin
              Consumer<ShopProvider>(
                builder: (context, shopProvider, child) {
                  final equippedSkin = shopProvider.equippedSkin;
                  final moleImagePath = shopProvider.getMoleImagePath();
                  
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mole with current skin
                        Image.asset(
                          moleImagePath,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          equippedSkin == null || equippedSkin.isEmpty
                              ? 'Default Mole'
                              : _getSkinName(equippedSkin),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select a skin:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Skins grid
              Expanded(
                child: Consumer<ShopProvider>(
                  builder: (context, shopProvider, child) {
                    final skins = shopProvider.getSkinItems();
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: skins.length + 1, // +1 for default mole
                      itemBuilder: (context, index) {
                        // First item is default mole
                        if (index == 0) {
                          final isEquipped = shopProvider.equippedSkin == null || 
                                            shopProvider.equippedSkin!.isEmpty;
                          return _buildSkinCard(
                            context: context,
                            skinId: '',
                            skinName: 'Default Mole',
                            imagePath: 'assets/images/33121063782.png',
                            isUnlocked: true,
                            isEquipped: isEquipped,
                            onTap: () => shopProvider.equipSkin(''),
                          );
                        }
                        
                        // Rest are custom skins
                        final skin = skins[index - 1];
                        final isEquipped = shopProvider.equippedSkin == skin.id;
                        
                        return _buildSkinCard(
                          context: context,
                          skinId: skin.id,
                          skinName: skin.name,
                          imagePath: skin.imagePath!,
                          isUnlocked: skin.isUnlocked,
                          isEquipped: isEquipped,
                          onTap: skin.isUnlocked
                              ? () => shopProvider.equipSkin(skin.id)
                              : null,
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

  Widget _buildSkinCard({
    required BuildContext context,
    required String skinId,
    required String skinName,
    required String imagePath,
    required bool isUnlocked,
    required bool isEquipped,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEquipped ? Colors.green : Colors.transparent,
            width: 3,
          ),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skin image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.purple.shade50
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: isUnlocked
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          imagePath,
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Icon(Icons.lock, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            
            // Skin name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                skinName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 4),
            
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (isEquipped ? Colors.green : Colors.grey.shade300)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isUnlocked
                    ? (isEquipped ? 'EQUIPPED ✓' : 'OWNED')
                    : 'LOCKED 🔒',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? (isEquipped ? Colors.white : Colors.black)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSkinName(String skinId) {
    const skinNames = {
      'skin_cowboy': 'Cowboy Mole',
      'skin_wizard': 'Wizard Mole',
      'skin_pirate': 'Pirate Mole',
      'skin_ninja': 'Ninja Mole',
    };
    return skinNames[skinId] ?? 'Custom Mole';
  }
}