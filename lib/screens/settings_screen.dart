import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/level_provider.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Color(0xFF232526), // Charcoal
                  Color(0xFF414345), // Slate
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
                      const Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balancing back button
                    ],
                  ),
                ),
                
                // ─── SETTINGS LIST ───────────────────────────
                Expanded(
                  child: Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        children: [
                          _buildSectionTitle('AUDIO'),
                          _GlassSettingTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Sound Effects',
                            trailing: _PremiumSwitch(
                              value: settings.soundEffects,
                              onChanged: (_) => settings.toggleSoundEffects(),
                            ),
                          ),
                          _GlassSettingTile(
                            icon: Icons.music_note_rounded,
                            title: 'Background Music',
                            trailing: _PremiumSwitch(
                              value: settings.backgroundMusic,
                              onChanged: (_) => settings.toggleBackgroundMusic(),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('NOTIFICATIONS'),
                          _GlassSettingTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'Push Notifications',
                            trailing: _PremiumSwitch(
                              value: settings.pushNotifications,
                              onChanged: (_) => settings.togglePushNotifications(),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('GENERAL'),
                          _GlassLanguageTile(
                            currentLanguage: settings.language,
                            onChanged: (val) => settings.setLanguage(val!),
                          ),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('ACCOUNT'),
                          _DangerActionTile(
                            icon: Icons.logout_rounded,
                            title: 'Sign Out',
                            onTap: () => _showPremiumSignOutDialog(context),
                          ),
                          const SizedBox(height: 12),
                          _DangerActionTile(
                            icon: Icons.delete_forever_rounded,
                            title: 'Delete Account',
                            isCritical: true,
                            onTap: () => _showPremiumDeleteDialog(context),
                          ),
                          
                          const SizedBox(height: 40),
                          _buildCreditsCard(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white54,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildCreditsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Column(
        children: [
          Text(
            'WHACK-A-MOLE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          SizedBox(height: 4),
          Text(
            'Version 1.0.0 Premium',
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Made with ❤️ for Ultimate Fun',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── DIALOGS ──────────────────────────────────────────

  void _showPremiumSignOutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: const Color(0xFF2C3E50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: const Text('SIGN OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            content: const Text('Are you sure you want to end your session?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPremiumDeleteDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: const Color(0xFF2C3E50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.redAccent, width: 2),
            ),
            title: const Text('DELETE ACCOUNT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This action is PERMANENT and cannot be undone.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'All progress, coins, and legendary skins will be lost forever.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _performDeletion(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('DELETE PERMANENTLY', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _performDeletion(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final levelProvider = Provider.of<LevelProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await shopProvider.resetData();
      levelProvider.resetAllLevels();
      final success = await authProvider.deleteAccount();

      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted.'), backgroundColor: Colors.green));
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? 'Failed'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

// ─── REUSABLE COMPONENTS ──────────────────────────────

class _GlassSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _GlassSettingTile({required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _GlassLanguageTile extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String?> onChanged;

  const _GlassLanguageTile({required this.currentLanguage, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.language_rounded, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Language',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(canvasColor: const Color(0xFF2C3E50)),
            child: DropdownButton<String>(
              value: currentLanguage,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              icon: const Icon(Icons.expand_more_rounded, color: Colors.amber),
              items: ['English', 'Spanish', 'French', 'German']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isCritical;

  const _DangerActionTile({required this.icon, required this.title, required this.onTap, this.isCritical = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCritical ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isCritical ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isCritical ? Colors.redAccent : Colors.white70, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: isCritical ? Colors.redAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isCritical ? Colors.red.withOpacity(0.5) : Colors.white24),
          ],
        ),
      ),
    );
  }
}

class _PremiumSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.amber,
      activeTrackColor: Colors.amber.withOpacity(0.3),
      inactiveThumbColor: Colors.white24,
      inactiveTrackColor: Colors.white10,
    );
  }
}

class _PremiumBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PremiumBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}