import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/achievements_screen.dart';
import 'models/game_state.dart';
import 'utils/audio_manager.dart';
import 'utils/statistics_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black,
  ));
  
  // Initialize audio manager
  await AudioManager().init();
  
  // Initialize statistics manager
  await StatisticsManager().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'SerKit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00FFFF),    // Cyan
            secondary: Color(0xFF9D4EDD),  // Purple
            tertiary: Color(0xFF4CC9F0),   // Electric blue
            background: Colors.black,
            surface: Color(0xFF121212),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Color(0xFF00FFFF)),
            displayMedium: TextStyle(color: Color(0xFF00FFFF)),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            foregroundColor: Color(0xFF00FFFF),
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/game': (context) => const GameScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/level_select': (context) => const LevelSelectScreen(),
          '/achievements': (context) => const AchievementsScreen(),
        },
      ),
    );
  }
}


