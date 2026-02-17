import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C7C8A),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFE0E0E0),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── AUDIO ──────────────────────────────────────
                const Text(
                  'Audio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  trailing: Switch(
                    value: settings.soundEffects,
                    activeColor: Colors.green,
                    onChanged: (_) => settings.toggleSoundEffects(),
                  ),
                ),
                _SettingTile(
                  icon: Icons.music_note,
                  title: 'Background Music',
                  trailing: Switch(
                    value: settings.backgroundMusic,
                    activeColor: Colors.green,
                    onChanged: (_) => settings.toggleBackgroundMusic(),
                  ),
                ),

                // ─── NOTIFICATIONS ──────────────────────────────
                const SizedBox(height: 24),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  trailing: Switch(
                    value: settings.pushNotifications,
                    activeColor: Colors.green,
                    onChanged: (_) => settings.togglePushNotifications(),
                  ),
                ),

                // ─── GENERAL ────────────────────────────────────
                const SizedBox(height: 24),
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 28),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: settings.language,
                        underline: const SizedBox.shrink(),
                        items: ['English', 'Spanish', 'French', 'German']
                            .map(
                              (String lang) => DropdownMenuItem<String>(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            settings?.setLanguage(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ─── ACCOUNT ────────────────────────────────────
                const SizedBox(height: 24),
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    _showSignOutDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 28, color: Colors.red.shade700),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red.shade700),
                      ],
                    ),
                  ),
                ),

                // ─── CREDITS ────────────────────────────────────
                const SizedBox(height: 24),
                const Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Whack-a-Mole Game',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Version 1.0.0'),
                      SizedBox(height: 8),
                      Text('Made with ❤️ for fun and learning'),
                      Text('© 2026 Whack-a-Mole.'),
                      Text('All rights reserved.'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);
              
              // Sign out using AuthProvider
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              
              // Navigate to login screen and remove all previous routes
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false, // Remove all previous routes
                );
              }
            },
            child: Text(
              'SIGN OUT',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE SETTING TILE ──────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}