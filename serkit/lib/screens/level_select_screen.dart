import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/background_grid.dart';
import '../widgets/level_card.dart';
import '../widgets/neon_button.dart';
import '../utils/audio_manager.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final int unlockedLevels = gameState.totalLevelsCompleted + 1;
    
    // Generate a list of all available levels
    final levelCount = 20; // Total number of levels in the game
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const BackgroundGrid(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeonButton(
                        onPressed: () {
                          Navigator.pop(context);
                          AudioManager().playSound('click');
                        },
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        'SELECT LEVEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 50), // For balance
                    ],
                  ),
                ),
                
                // Level grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: levelCount,
                      itemBuilder: (context, index) {
                        final levelNumber = index + 1;
                        final isUnlocked = levelNumber <= unlockedLevels;
                        final isCompleted = levelNumber < unlockedLevels;
                        
                        return LevelCard(
                          levelNumber: levelNumber,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          onTap: isUnlocked ? () {
                            // Set the current level and navigate to the game screen
                            gameState.currentLevel = levelNumber;
                            AudioManager().playSound('click');
                            Navigator.pushNamed(context, '/game');
                          } : null,
                        );
                      },
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
