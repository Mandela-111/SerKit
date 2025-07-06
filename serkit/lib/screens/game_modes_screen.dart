import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/game_mode.dart';
import '../widgets/background_grid.dart';
import '../utils/audio_manager.dart';

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final List<GameMode> availableModes = GameMode.allModes();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Game Modes'),
      ),
      body: Stack(
        children: [
          const BackgroundGrid(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Game Mode',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableModes.length,
                      itemBuilder: (context, index) {
                        final mode = availableModes[index];
                        final isSelected = gameState.gameMode.type == mode.type;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildGameModeCard(
                            context,
                            mode: mode,
                            isSelected: isSelected,
                            onTap: () {
                              AudioManager().playSound('click');
                              gameState.setGameMode(mode.type);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameModeCard(
    BuildContext context, {
    required GameMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? mode.color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mode.color.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      mode.icon,
                      color: mode.color,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mode.color,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: mode.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'SELECTED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: mode.color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mode.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameModeSpecificDetails(mode),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeSpecificDetails(GameMode mode) {
    switch (mode.type) {
      case GameModeType.classic:
        return const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white54, size: 16),
            SizedBox(width: 8),
            Text(
              'Play at your own pace',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        );
        
      case GameModeType.timeAttack:
        final initialTime = mode.settings['initialTimeSeconds'] as int;
        final timeBonusPerLevel = mode.settings['timePerLevelBonus'] as int;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Initial time: $initialTime seconds',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  '+$timeBonusPerLevel seconds per completed level',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        );
        
      case GameModeType.expert:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.white54, size: 16),
                SizedBox(width: 8),
                Text(
                  'Limited moves to complete each level',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.grid_on, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Complexity: ${mode.settings['complexityFactor']}x',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        );
    }
  }
}
