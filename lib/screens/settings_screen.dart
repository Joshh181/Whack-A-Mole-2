import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/level_provider.dart';
import '../providers/game_provider.dart';
import 'auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
// setting screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
// build method 
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
          // safe area
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
                          _GlassSettingTile(
                            icon: Icons.vibration_rounded,
                            title: 'Haptic Feedback',
                            trailing: _PremiumSwitch(
                              value: settings.hapticFeedback,
                              onChanged: (_) => settings.toggleHapticFeedback(),
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
                          _buildSectionTitle('SUPPORT & LEGAL'),
                          _SupportTile(
                            icon: Icons.policy_rounded,
                            title: 'Privacy Policy',
                            onTap: () => _showPrivacyPolicy(context),
                          ),
                          _SupportTile(
                            icon: Icons.contact_support_rounded,
                            title: 'Contact Support',
                            onTap: () => _showContactSupport(context),
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
//build section title
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
//build credits card
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
            'Version 1.0.0',
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1),
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
                  final shopProvider = Provider.of<ShopProvider>(context, listen: false);
                  final levelProvider = Provider.of<LevelProvider>(context, listen: false);
                  final gameProvider = Provider.of<GameProvider>(context, listen: false);
                  
                  // Reset providers memory state before sign out
                  shopProvider.resetData();
                  levelProvider.clearCache();
                  gameProvider.resetData();
                  
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
// show delete dialog
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
// perform deletion
  void _performDeletion(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
// perform deletion
    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final levelProvider = Provider.of<LevelProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      shopProvider.resetData();
      levelProvider.resetAllLevels();
      gameProvider.resetData();
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
// show privacy policy
  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GlassSheet(
        title: 'PRIVACY POLICY',
        content: '''
Last Updated: April 2026

1. DATA COLLECTION
We only collect basic game progress data (high scores, coins, and unlocked skins) to provide you with a persistent gaming experience.

2. LOCAL STORAGE
All game settings and progress are stored locally on your device using shared preferences and may be synced if you use our cloud services.

3. THIRD PARTY SERVICES
We do not sell your data. We use standard analytical tools to improve game performance and identify bugs.

4. USER RIGHTS
You can request account deletion at any time via the Settings menu, which will permanently remove all your data from our servers.
        ''',
      ),
    );
  }
// launch email
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'josh.lumactod16@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Support Request - Whack-a-Mole',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }
// encode query parameters
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
// show contact support
  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SupportSheet(
        title: 'CONTACT SUPPORT',
        email: 'josh.lumactod16@gmail.com',
        content: '''
Need help with your moles?

We typically respond within 24-48 hours.

💡 TIP:
Include your User ID in the email for faster service. You can find your ID in the Account section.
        ''',
        onEmailTap: _launchEmail,
      ),
    );
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

// danger action tile
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

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SupportTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
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

class _GlassSheet extends StatelessWidget {
  final String title;
  final String content;

  const _GlassSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    content,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SupportSheet extends StatelessWidget {
  final String title;
  final String content;
  final String email;
  final VoidCallback onEmailTap;

  const _SupportSheet({
    required this.title,
    required this.content,
    required this.email,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    content,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  
                  // Interactive Email Card
                  GestureDetector(
                    onTap: onEmailTap,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.email_rounded, color: Colors.amber),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SEND US AN EMAIL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.open_in_new_rounded, color: Colors.white24, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
