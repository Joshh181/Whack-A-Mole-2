import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/level_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/shop_provider.dart';

// Screens
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ubsxqnlclqwbufbfyolh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVic3hxbmxjbHF3YnVmYmZ5b2xoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwMDU3MjYsImV4cCI6MjA4NTU4MTcyNn0.xDuNvwoNk-7O0zfLiAQ3lBNCCOEO8EkV9MbLWiKtHgA',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: const WhackAMoleApp(),
    ),
  );
}

class WhackAMoleApp extends StatelessWidget {
  const WhackAMoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL FIX: Load user data when authenticated
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Load shop data when user logs in
        if (authProvider.isAuthenticated) {
          final shopProvider = Provider.of<ShopProvider>(context, listen: false);
          
          // Only load if not already loaded for this user
          if (!shopProvider.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              debugPrint('🔄 Loading user data...');
              shopProvider.loadUserData();
            });
          }
        }
        
        return MaterialApp(
          title: 'Whack-a-Mole',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.lilitaOneTextTheme(),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}