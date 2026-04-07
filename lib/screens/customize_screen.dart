import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../services/audio_service.dart';
import '../models/shop_item.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final audioService = AudioService();
    final ownedSkins = shopProvider.items
        .where((item) => item.type == ShopItemType.customization && item.isUnlocked)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // ─── BACKGROUND ─────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF311B92), // Deep Purple
                  Color(0xFF4527A0), // Deep Purple
                  Color(0xFF512DA8), // Deep Purple
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // ─── CUSTOM TOP BAR ──────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      _PremiumBackButton(onPressed: () => Navigator.pop(context)),
                      const Spacer(),
                    ],
                  ),
                ),
                
                // ─── TITLE & PREVIEW ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CUSTOMIZE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'EQUIP YOUR LEGENDARY SKINS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Active Skin Preview
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: (shopProvider.equippedSkin == null || shopProvider.equippedSkin!.isEmpty)
                              ? Image.asset('assets/images/MOLEE.png', width: 120, height: 120, fit: BoxFit.contain)
                              : Image.asset(
                                  shopProvider.items.firstWhere((i) => i.id == shopProvider.equippedSkin).imagePath ?? 'assets/images/MOLEE.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    shopProvider.items.firstWhere((i) => i.id == shopProvider.equippedSkin).iconEmoji,
                                    style: const TextStyle(fontSize: 80),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // ─── SKIN GRID ──────────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: ownedSkins.length + 1, // +1 for default
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Default Skin
                          final isEquipped = shopProvider.equippedSkin == null || shopProvider.equippedSkin!.isEmpty;
                          return _SkinCard(
                            imagePath: 'assets/images/MOLEE.png',
                            name: 'DEFAULT',
                            isEquipped: isEquipped,
                            onTap: () {
                              audioService.playButtonClick();
                              shopProvider.equipSkin('');
                            },
                          );
                        }
                        
                        final item = ownedSkins[index - 1];
                        final isEquipped = shopProvider.equippedSkin == item.id;
                        
                        return _SkinCard(
                          imagePath: item.imagePath,
                          iconEmoji: item.iconEmoji,
                          name: item.name.split(' ').first.toUpperCase(),
                          isEquipped: isEquipped,
                          onTap: () {
                            audioService.playButtonClick();
                            shopProvider.equipSkin(item.id);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PREMIUM BACK BUTTON ──────────────────────────────
class _PremiumBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PremiumBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

// ─── SKIN SELECTION CARD ──────────────────────────────
class _SkinCard extends StatelessWidget {
  final String? imagePath;
  final String? iconEmoji;
  final String name;
  final bool isEquipped;
  final VoidCallback onTap;

  const _SkinCard({
    this.imagePath,
    this.iconEmoji,
    required this.name,
    required this.isEquipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isEquipped ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isEquipped ? Colors.amber : Colors.white.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: isEquipped ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : [],
              ),
              child: Center(
                child: imagePath != null
                    ? Image.asset(imagePath!, width: 45, height: 45, fit: BoxFit.contain)
                    : Text(
                        iconEmoji ?? '🦫',
                        style: const TextStyle(fontSize: 30),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEquipped ? 'EQUIPPED' : name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isEquipped ? Colors.amber : Colors.white54,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}