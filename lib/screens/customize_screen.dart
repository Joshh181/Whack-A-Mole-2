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
    final ownedMallets = shopProvider.items
        .where((item) => item.type == ShopItemType.mallet && item.isUnlocked)
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
                              'EQUIP YOUR LEGENDARY GEAR',
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
                      const SizedBox(height: 24),
                      
                      // Active Skin + Mallet Preview Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Skin Preview
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: (shopProvider.equippedSkin == null || shopProvider.equippedSkin!.isEmpty)
                                  ? Image.asset('assets/images/MOLEE.png', width: 85, height: 85, fit: BoxFit.contain)
                                  : Image.asset(
                                      shopProvider.items.firstWhere((i) => i.id == shopProvider.equippedSkin).imagePath ?? 'assets/images/MOLEE.png',
                                      width: 85,
                                      height: 85,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        shopProvider.items.firstWhere((i) => i.id == shopProvider.equippedSkin).iconEmoji,
                                        style: const TextStyle(fontSize: 60),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Mallet Preview
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                shopProvider.getEquippedMalletEmoji(),
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // ─── SKINS + MALLETS SECTIONS ────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 40),
                      children: [
                        // ── SKINS HEADER ──
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '🎭  SKINS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        // ── SKINS GRID ──
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: ownedSkins.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
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
                        
                        const SizedBox(height: 32),
                        
                        // ── MALLETS HEADER ──
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '🔨  MALLETS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        // ── MALLETS GRID ──
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: ownedMallets.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isEquipped = shopProvider.equippedMallet == null || shopProvider.equippedMallet!.isEmpty;
                              return _SkinCard(
                                iconEmoji: '🔨',
                                name: 'DEFAULT',
                                isEquipped: isEquipped,
                                onTap: () {
                                  audioService.playButtonClick();
                                  shopProvider.equipMallet('');
                                },
                              );
                            }
                            final item = ownedMallets[index - 1];
                            final isEquipped = shopProvider.equippedMallet == item.id;
                            return _SkinCard(
                              iconEmoji: item.iconEmoji,
                              name: item.name.split(' ').first.toUpperCase(),
                              isEquipped: isEquipped,
                              onTap: () {
                                audioService.playButtonClick();
                                shopProvider.equipMallet(item.id);
                              },
                            );
                          },
                        ),
                      ],
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