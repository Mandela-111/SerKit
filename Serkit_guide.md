# Flutter Circuit Puzzle Game - AI Development Guide

## Project Overview
Create a Flutter mobile puzzle game inspired by circuit-connecting mechanics, featuring neon aesthetics and progressive difficulty.

## Core Game Mechanics
- **Objective**: Connect energy nodes to complete electrical circuits
- **Gameplay**: Tap and drag to trace connections between nodes
- **Victory Condition**: All nodes connected in a complete circuit
- **Aesthetics**: Dark cyberpunk theme with glowing neon connections

## Detailed Prompts for AI Coding Tools

### 1. Project Setup Prompt
```
Create a new Flutter project for a puzzle game called "Circuit Flow". Set up the basic project structure with:
- main.dart with MaterialApp
- A dark theme with neon accent colors (cyan, purple, electric blue)
- Screen navigation setup for: Home, Game, Settings, Levels
- Add dependencies for: flutter_svg, audioplayers, shared_preferences
```

### 2. Game Board Structure Prompt
```
Create a Flutter widget called GameBoard that:
- Displays a grid of electrical nodes (circular widgets)
- Each node can be in states: inactive, active, connected
- Nodes have glowing effects when active using Container with BoxDecoration
- Implement a CustomPainter to draw connection lines between nodes
- Use a 2D array to represent the board state
- Make nodes tappable with GestureDetector
```

### 3. Connection Drawing System Prompt
```
Implement a connection drawing system in Flutter that:
- Tracks finger movement from one node to another
- Uses CustomPainter to draw glowing lines during drag
- Validates connections (nodes must be adjacent or follow game rules)
- Animates connection appearance with tweening
- Prevents crossing connections or invalid paths
- Stores connection data in a graph structure
```

### 4. Game Logic Prompt
```
Create game logic for the circuit puzzle that:
- Checks if all nodes are connected in a valid circuit
- Implements circuit validation (no broken connections)
- Handles win conditions and level completion
- Manages game state (playing, paused, won, failed)
- Tracks player progress and moves
- Implements undo functionality for connections
```

### 5. Visual Effects Prompt
```
Add visual effects to the Flutter game using:
- Animated glowing effects on nodes using AnimatedContainer
- Particle effects for successful connections
- Pulsing animations for active nodes
- Smooth color transitions for state changes
- Custom shaders for neon glow effects if possible
- Screen shake animation for successful level completion
```

### 6. Level System Prompt
```
Create a level progression system that:
- Stores levels in JSON format with node positions and connection rules
- Implements difficulty progression (more nodes, complex shapes)
- Saves player progress using shared_preferences
- Unlocks levels sequentially
- Displays level selection screen with progress indicators
- Includes level categories: Tutorial, Classic, Challenge, Master
```

### 7. UI/UX Design Prompts
```
Design the UI screens with cyberpunk aesthetic:
- Dark background with subtle grid patterns
- Neon accent colors for buttons and highlights
- Glowing text effects using custom TextStyle
- Animated background particles or circuits
- Clean, minimal interface focusing on the puzzle
- Custom icons for electrical/circuit theme
```

### 8. Audio Integration Prompt
```
Implement audio system for the game:
- Background ambient electronic music
- Sound effects for: node selection, connection made, level complete, error
- Audio feedback for UI interactions
- Volume controls in settings
- Use audioplayers package for sound management
```

### 9. Game Modes Prompt
```
Implement different game modes:
- Classic Mode: Relaxed puzzle solving
- Timed Mode: Complete circuits within time limit
- Challenge Mode: Limited moves or special constraints
- Zen Mode: Infinite time, focus on relaxation
- Daily Puzzle: New puzzle each day
```

### 10. Performance Optimization Prompt
```
Optimize the Flutter game for performance:
- Use RepaintBoundary for game board area
- Implement object pooling for visual effects
- Optimize CustomPainter drawing calls
- Use const constructors where possible
- Implement lazy loading for level data
- Add FPS monitoring in debug mode
```

## Key Flutter Widgets to Use
- **CustomPainter**: For drawing connections and effects
- **GestureDetector**: For touch interactions
- **AnimatedContainer**: For node animations
- **TweenAnimationBuilder**: For smooth transitions
- **Stack**: For layering game elements
- **GridView**: For level selection
- **SharedPreferences**: For save data

## Game State Management
```dart
// Example game state structure
class GameState {
  List<List<Node>> board;
  List<Connection> connections;
  GameStatus status;
  int currentLevel;
  int moves;
  Duration timeElapsed;
}
```

## Technical Implementation Tips
1. **Performance**: Use RepaintBoundary around the game board
2. **Touch Handling**: Implement proper touch event filtering
3. **State Management**: Use Provider or Riverpod for game state
4. **Testing**: Create unit tests for game logic
5. **Accessibility**: Add semantic labels for screen readers

## Sample Level Format
```json
{
  "level": 1,
  "difficulty": "easy",
  "nodes": [
    {"x": 1, "y": 1, "type": "start"},
    {"x": 3, "y": 1, "type": "end"},
    {"x": 2, "y": 2, "type": "junction"}
  ],
  "required_connections": 2,
  "time_limit": null
}
```

## Specific Prompts for Each Development Phase

### Phase 1: Core Setup
"Create the main game structure with a dark theme and basic navigation between home screen and game screen."

### Phase 2: Basic Gameplay
"Implement the core connection drawing mechanism where users can drag between nodes to create glowing connections."

### Phase 3: Game Logic
"Add win condition checking and level progression system with simple puzzle validation."

### Phase 4: Visual Polish
"Enhance the visual effects with animations, particle effects, and cyberpunk styling."

### Phase 5: Content & Features
"Add multiple game modes, level selection, and save/load functionality."

## Testing Prompts
```
Create Flutter widget tests for:
- Game board initialization
- Connection validation logic
- Level completion detection
- Save/load game state
- UI interaction handling
```

