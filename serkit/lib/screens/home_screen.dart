import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/neon_button.dart';
import '../widgets/background_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Cyberpunk background with grid
          const BackgroundGrid(),
          
          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game title with glow effect
                  const Text(
                    'SerKit',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FFFF),
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Color(0xFF00FFFF),
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Subtitle
                  const Text(
                    'Circuit Flow Puzzle',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Play button
                  NeonButton(
                    text: 'PLAY',
                    onPressed: () => Navigator.pushNamed(context, '/level_select'),
                    width: size.width * 0.7,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Continue button (only if levels are completed)
                  if (gameState.totalLevelsCompleted > 0)
                    NeonButton(
                      text: 'CONTINUE',
                      onPressed: () => Navigator.pushNamed(
                        context, 
                        '/game',
                        arguments: {'level': gameState.currentLevel}
                      ),
                      width: size.width * 0.7,
                      color: const Color(0xFF9D4EDD),
                    ),
                  
                  if (gameState.totalLevelsCompleted > 0)
                    const SizedBox(height: 20),
                  
                  // Settings button
                  NeonButton(
                    text: 'SETTINGS',
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    width: size.width * 0.7,
                    color: const Color(0xFF4CC9F0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
