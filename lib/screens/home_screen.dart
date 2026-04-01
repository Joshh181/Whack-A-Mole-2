import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../services/audio_service.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'daily_rewards_screen.dart';
import 'shop_screen.dart';
import 'customize_screen.dart';
import 'leaderboard_screen.dart';
import '../screens/level_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky Blue
              Color(0xFFE1BEE7), // Soft Purple mist bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── TOP BAR ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Customize button (Circle 3D)
                    GestureDetector(
                      onTap: () {
                        audioService.playButtonClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomizeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300), // Amber
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE65100), // Dark Amber
                              offset: const Offset(0, 5),
                              blurRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2, left: 10, right: 10, height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                                ),
                              ),
                            ),
                            const Center(
                              child: Icon(
                                Icons.palette_rounded,
                                color: Colors.white,
                                size: 30,
                                shadows: [Shadow(color: Color(0xFFE65100), offset: Offset(0, 2), blurRadius: 2)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Coins display (Teal Pill 3D)
                    Consumer<ShopProvider>(
                      builder: (context, shopProvider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26A69A), // Teal
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0xFF00695C), 
                                offset: Offset(0, 4),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '💰',
                                style: TextStyle(
                                  fontSize: 22,
                                  shadows: [Shadow(color: Colors.black38, offset: Offset(0, 2))],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${shopProvider.coins}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [Shadow(color: Color(0xFF00695C), offset: Offset(0, 2))],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // ─── MOLE CHARACTER ──────────────────────────
              Consumer<ShopProvider>(
                builder: (context, shopProvider, child) {
                  return Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF87CEEB).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/MOLE.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // ─── TITLE ───────────────────────────────────
              Stack(
                children: [
                  // Text stroke
                  Text(
                    'WHACK A MOLE',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
                        ..color = Colors.black26,
                    ),
                  ),
                  const Text(
                    'WHACK A MOLE',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // ─── MENU BUTTONS ────────────────────────────
              _MenuButton(
                label: 'PLAY',
                icon: Icons.play_arrow_rounded,
                color: const Color(0xFF00E676), // Vibrant Green
                darkColor: const Color(0xFF00C853),
                onPressed: () {
                  audioService.playButtonClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              _MenuButton(
                label: 'LEADERBOARD',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFFFB300), // Amber
                darkColor: const Color(0xFFFF8F00),
                onPressed: () {
                  audioService.playButtonClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _MenuButton(
                label: 'ACHIEVEMENTS',
                icon: Icons.stars_rounded,
                color: const Color(0xFFCDDC39), // Lime Add
                darkColor: const Color(0xFFAFB42B),
                onPressed: () {
                  audioService.playButtonClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _MenuButton(
                label: 'OPTIONS',
                icon: Icons.settings_rounded,
                color: const Color(0xFF9E9E9E), // Grey
                darkColor: const Color(0xFF616161),
                onPressed: () {
                  audioService.playButtonClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ─── BOTTOM ROW (DAILY + SHOP) ───────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconButton(
                    icon: Icons.calendar_today_rounded,
                    label: 'DAILY',
                    color: const Color(0xFF42A5F5), // Light Blue
                    darkColor: const Color(0xFF1E88E5), // Dark Blue
                    onPressed: () {
                      audioService.playButtonClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyRewardsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _IconButton(
                    icon: Icons.shopping_cart_rounded,
                    label: 'SHOP',
                    color: const Color(0xFFFF5252), // Red Accent
                    darkColor: const Color(0xFFD50000), // Dark Red
                    onPressed: () {
                      audioService.playButtonClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── REUSABLE MENU BUTTON (3D Bubble Style) ────────────────────────
class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color darkColor;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.darkColor,
    required this.onPressed,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 300,
        height: 65,
        margin: EdgeInsets.only(top: _isPressed ? 6 : 0, bottom: _isPressed ? 0 : 6),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(35),
          boxShadow: _isPressed 
            ? [] // No shadow when pressed down
            : [
                BoxShadow(
                  color: widget.darkColor,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 10),
                  blurRadius: 15,
                ),
              ],
        ),
        child: Stack(
          children: [
            // Glossy Highlight
            Positioned(
              top: 0, left: 20, right: 20, height: 25,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)],
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon, 
                    size: 28, 
                    color: Colors.white,
                    shadows: [Shadow(color: widget.darkColor, offset: const Offset(0, 2), blurRadius: 2)],
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: widget.darkColor, offset: const Offset(0, 2), blurRadius: 2)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── REUSABLE ICON BUTTON (DAILY / SHOP) ──────────────────────────
class _IconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color darkColor;
  final VoidCallback onPressed;

  const _IconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.darkColor,
    required this.onPressed,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 110,
        height: 110,
        margin: EdgeInsets.only(top: _isPressed ? 6 : 0, bottom: _isPressed ? 0 : 6),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: _isPressed
            ? []
            : [
                BoxShadow(
                  color: widget.darkColor,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 10),
                  blurRadius: 15,
                ),
              ],
        ),
        child: Stack(
          children: [
            // Glossy Highlight
            Positioned(
              top: 0, left: 10, right: 10, height: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon, 
                    size: 42, 
                    color: Colors.white,
                    shadows: [Shadow(color: widget.darkColor, offset: const Offset(0, 2), blurRadius: 2)],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(color: widget.darkColor, offset: const Offset(0, 2), blurRadius: 2)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}