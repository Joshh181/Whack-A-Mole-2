import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/level_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/shop_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'services/haptic_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// load .env file
  await dotenv.load(fileName: ".env");
// Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
// whack a mole app
class WhackAMoleApp extends StatelessWidget {
  const WhackAMoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize HapticService with SettingsProvider
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    HapticService().init(settings);

    // ✅ CRITICAL FIX: Load user data when authenticated
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Load shop data when user logs in
        if (authProvider.isAuthenticated) {
          final shopProvider = Provider.of<ShopProvider>(context, listen: false);
          final levelProvider = Provider.of<LevelProvider>(context, listen: false);
          final gameProvider = Provider.of<GameProvider>(context, listen: false);
          
          // Only load if not already loaded for this user
          if (!shopProvider.isInitialized || !levelProvider.isInitialized || !gameProvider.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              debugPrint('🔄 Loading user data...');
              if (!shopProvider.isInitialized) shopProvider.loadUserData();
              if (!levelProvider.isInitialized) levelProvider.loadUserData();
              if (!gameProvider.isInitialized) gameProvider.loadUserData();
            });
          }
        }
        
        return MaterialApp(
          title: 'Whack-a-Mole',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.fredokaTextTheme(),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}