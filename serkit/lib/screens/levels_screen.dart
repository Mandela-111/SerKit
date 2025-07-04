import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/background_grid.dart';
import '../widgets/level_card.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    // Level categories with their respective level counts
    final levelCategories = [
      {'name': 'Tutorial', 'levels': 3},
      {'name': 'Classic', 'levels': 10},
      {'name': 'Challenge', 'levels': 8},
      {'name': 'Master', 'levels': 5},
    ];
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Select Level'),
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
                  // Game mode selector
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00FFFF).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: gameState.currentGameMode,
                      dropdownColor: const Color(0xFF121212),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00FFFF)),
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Color(0xFF00FFFF)),
                      items: const [
                        DropdownMenuItem(
                          value: 'Classic',
                          child: Text('Classic Mode'),
                        ),
                        DropdownMenuItem(
                          value: 'Timed',
                          child: Text('Timed Mode'),
                        ),
                        DropdownMenuItem(
                          value: 'Challenge',
                          child: Text('Challenge Mode'),
                        ),
                        DropdownMenuItem(
                          value: 'Zen',
                          child: Text('Zen Mode'),
                        ),
                      ],
                      onChanged: (newValue) {
                        if (newValue != null) {
                          gameState.currentGameMode = newValue;
                          gameState.saveGameState();
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Level categories
                  Expanded(
                    child: ListView.builder(
                      itemCount: levelCategories.length,
                      itemBuilder: (context, index) {
                        final category = levelCategories[index];
                        final String categoryName = category['name'] as String;
                        final int levelCount = category['levels'] as int;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00FFFF),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: levelCount,
                                itemBuilder: (context, levelIndex) {
                                  final int globalLevelIndex = _calculateGlobalLevelIndex(
                                    levelCategories, 
                                    index, 
                                    levelIndex
                                  );
                                  
                                  final bool isUnlocked = globalLevelIndex <= gameState.totalLevelsCompleted + 1;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: LevelCard(
                                      levelNumber: globalLevelIndex,
                                      isUnlocked: isUnlocked,
                                      isCompleted: globalLevelIndex <= gameState.totalLevelsCompleted,
                                      onTap: isUnlocked ? () {
                                        Navigator.pushNamed(
                                          context,
                                          '/game',
                                          arguments: {'level': globalLevelIndex},
                                        );
                                      } : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
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
  
  /// Calculate the global level index based on category and local level index
  int _calculateGlobalLevelIndex(List<Map<String, dynamic>> categories, int categoryIndex, int levelIndex) {
    int globalIndex = levelIndex + 1; // 1-based indexing for levels
    
    // Add the level counts of previous categories
    for (int i = 0; i < categoryIndex; i++) {
      globalIndex += categories[i]['levels'] as int;
    }
    
    return globalIndex;
  }
}
