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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    
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
                  Color(0xFF1A237E), // Deep Indigo
                  Color(0xFF311B92), // Deep Purple
                  Color(0xFF880E4F), // Maroon/Wine
                ],
              ),
            ),
          ),
          
          // Subtle background glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ─── TOP BAR ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Customize button (Glassmorphism)
                      _GlassIconButton(
                        icon: Icons.palette_rounded,
                        color: Colors.amber,
                        onPressed: () {
                          audioService.playButtonClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CustomizeScreen()),
                          );
                        },
                      ),
                      
                      // Coins display (Glassmorphism Pill)
                      Consumer<ShopProvider>(
                        builder: (context, shopProvider, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Text('💰', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  '${shopProvider.coins}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1,
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

                // ─── MOLE CHARACTER (Floating) ────────────────
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_floatAnimation.value),
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'mole_icon',
                            child: Image.asset(
                              'assets/images/MOLEE.png',
                              width: 170,
                              height: 170, 
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ─── TITLE (Premium styling) ─────────────────
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFB3E5FC)],
                  ).createShader(bounds),
                  child: const Text(
                    'WHACK A MOLE',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 12),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),

                // ─── MENU BUTTONS (Premium Glassmorphism) ─────
                _PremiumMenuButton(
                  label: 'PLAY NOW',
                  icon: Icons.play_arrow_rounded,
                  gradient: const [Color(0xFF00E676), Color(0xFF00C853)],
                  onPressed: () {
                    audioService.playButtonClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _PremiumMenuButton(
                  label: 'LEADERBOARD',
                  icon: Icons.emoji_events_rounded,
                  gradient: const [Color(0xFFFFD600), Color(0xFFFFAB00)],
                  onPressed: () {
                    audioService.playButtonClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SmallMenuButton(
                      label: 'TROPHIES',
                      icon: Icons.stars_rounded,
                      onPressed: () {
                        audioService.playButtonClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _SmallMenuButton(
                      label: 'SETTINGS',
                      icon: Icons.settings_rounded,
                      onPressed: () {
                        audioService.playButtonClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // ─── BOTTOM ROW (DAILY + SHOP) ───────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BottomActionCard(
                          icon: Icons.calendar_today_rounded,
                          label: 'DAILY REWARD',
                          color: const Color(0xFF42A5F5),
                          onPressed: () {
                            audioService.playButtonClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DailyRewardsScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _BottomActionCard(
                          icon: Icons.shopping_basket_rounded,
                          label: 'MARKETPLACE',
                          color: const Color(0xFFFF5252),
                          onPressed: () {
                            audioService.playButtonClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ShopScreen()),
                            );
                          },
                        ),
                      ),
                    ],
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

// ─── PREMIUM GLASS ICON BUTTON ──────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

// ─── PREMIUM MENU BUTTON ────────────────────────────────────
class _PremiumMenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onPressed;

  const _PremiumMenuButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onPressed,
  });

  @override
  State<_PremiumMenuButton> createState() => _PremiumMenuButtonState();
}

class _PremiumMenuButtonState extends State<_PremiumMenuButton> {
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
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 320,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SMALL MENU BUTTON ───────────────────────────────────────
class _SmallMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SmallMenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 152,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BOTTOM ACTION CARD ──────────────────────────────────────
class _BottomActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _BottomActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}