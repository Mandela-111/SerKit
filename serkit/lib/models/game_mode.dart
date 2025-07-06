import 'package:flutter/material.dart';

/// Defines different game modes that offer varied gameplay experiences
enum GameModeType {
  classic,
  timeAttack,
  expert,
}

/// Class that defines the rules and properties of a game mode
class GameMode {
  final GameModeType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> settings;
  
  const GameMode({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.settings = const {},
  });
  
  /// Get a specific game mode by type
  factory GameMode.fromType(GameModeType type) {
    switch (type) {
      case GameModeType.classic:
        return GameMode(
          type: GameModeType.classic,
          name: 'Classic',
          description: 'Connect the circuits at your own pace.',
          icon: Icons.lightbulb_outline,
          color: Colors.cyan,
        );
        
      case GameModeType.timeAttack:
        return GameMode(
          type: GameModeType.timeAttack,
          name: 'Time Attack',
          description: 'Race against the clock to complete circuits before time runs out!',
          icon: Icons.timer,
          color: Colors.orange,
          settings: {
            'initialTimeSeconds': 60, // Starting time
            'timePerLevelBonus': 15,  // Additional time when completing a level
            'timePerConnectionBonus': 2, // Time bonus per successful connection
          },
        );
        
      case GameModeType.expert:
        return GameMode(
          type: GameModeType.expert,
          name: 'Expert',
          description: 'Solve complex circuits with limited moves.',
          icon: Icons.science,
          color: Colors.purple,
          settings: {
            'movePenaltyFactor': 1.5, // Expert mode allows fewer moves
            'complexityFactor': 1.5,  // More complex circuits
          },
        );
    }
  }
  
  /// Get list of all available game modes
  static List<GameMode> allModes() {
    return [
      GameMode.fromType(GameModeType.classic),
      GameMode.fromType(GameModeType.timeAttack),
      GameMode.fromType(GameModeType.expert),
    ];
  }
  
  /// Convert a string representation to GameModeType enum
  static GameModeType typeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'timeattack':
        return GameModeType.timeAttack;
      case 'expert':
        return GameModeType.expert;
      default:
        return GameModeType.classic;
    }
  }
  
  /// Convert GameModeType enum to string representation
  static String typeToString(GameModeType type) {
    switch (type) {
      case GameModeType.timeAttack:
        return 'TimeAttack';
      case GameModeType.expert:
        return 'Expert';
      default:
        return 'Classic';
    }
  }
}
