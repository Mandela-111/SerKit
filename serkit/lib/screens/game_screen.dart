import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/connection.dart';

import '../widgets/game_board.dart';
import '../utils/audio_manager.dart';
import '../widgets/background_grid.dart';
import '../widgets/neon_button.dart';
import '../utils/level_loader.dart';
import '../widgets/undo_effect.dart';
import '../widgets/countdown_timer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _winAnimationController;
  bool _isLevelLoaded = false;
  final GlobalKey _boardKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _winAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Play game background music
    AudioManager().playMusic('game');
    
    // Load level after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevel();
    });
  }
  
  @override
  void dispose() {
    _winAnimationController.dispose();
    
    // Stop game music when leaving the game screen
    AudioManager().stopMusic();
    
    super.dispose();
  }
  
  void _loadLevel() async {
    final gameState = Provider.of<GameState>(context, listen: false);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final levelNumber = args != null ? args['level'] as int : gameState.currentLevel;
    
    final levelData = await LevelLoader.loadLevel(levelNumber);
    
    if (mounted) {
      gameState.initializeBoard(levelData);
      setState(() {
        _isLevelLoaded = true;
      });
    }
  }
  
  void _onConnectionAdded() {
    // Play connection sound
    AudioManager().playSound('connect');
    
    // Check win condition
    _checkWinCondition();
  }
  
  void _onConnectionRemoved() {
    // Play disconnect sound
    AudioManager().playSound('disconnect');
  }
  
  void _undoLastMove() {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Store the last removed connection position for undo effect
    Connection? lastRemovedConnection;
    if (gameState.actionHistory.isNotEmpty) {
      final lastAction = gameState.actionHistory.last;
      if (lastAction.type == ActionType.addConnection) {
        lastRemovedConnection = lastAction.connection;
      }
    }
    
    // Try to undo the last action
    if (gameState.undo()) {
      // Play click sound on successful undo
      AudioManager().playSound('click');
      
      // Show undo effect animation if there was a connection removed
      if (lastRemovedConnection != null) {
        _showUndoEffect(lastRemovedConnection);
      }
    } else {
      // Play error sound if nothing to undo
      AudioManager().playSound('error');
    }
  }
  
  void _showUndoEffect(Connection connection) {
    // Get the board widget's render box position
    final RenderBox? renderBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    // Get position in board
    final boardSize = renderBox.size;
    final cellSize = boardSize.width / 8; // Assuming 8x8 grid
    
    // Calculate position of the connection midpoint
    final startNode = connection.startNode;
    final endNode = connection.endNode;
    
    final startPos = Offset(
      (startNode.col * cellSize) + (cellSize / 2),
      (startNode.row * cellSize) + (cellSize / 2),
    );
    
    final endPos = Offset(
      (endNode.col * cellSize) + (cellSize / 2),
      (endNode.row * cellSize) + (cellSize / 2),
    );
    
    // Calculate midpoint of the connection
    final midPoint = Offset(
      (startPos.dx + endPos.dx) / 2,
      (startPos.dy + endPos.dy) / 2,
    );
    
    // Get the global position
    final globalPosition = renderBox.localToGlobal(midPoint);
    
    // Show the undo effect at this position
    _showUndoEffectOverlay(globalPosition);
  }
  
  void _showUndoEffectOverlay(Offset position) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx - 50,
            top: position.dy - 50,
            child: UndoEffect(
              position: const Offset(50, 50),
              color: const Color(0xFF00FFFF),
            ),
          ),
        ],
      ),
    );
  }
  
  void _checkWinCondition() {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.status == GameStatus.won) {
      // Play win sound
      AudioManager().playSound('win');
      
      // Start win animation
      _winAnimationController.forward(from: 0).whenComplete(() {
        // Show win dialog after animation completes
        _showWinDialog();
      });
    } else if (gameState.status == GameStatus.failed) {
      // Show failure dialog for Time Attack mode when time runs out
      _showFailureDialog();
    }
  }
  
  void _showWinDialog() {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF00FFFF),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'LEVEL COMPLETE',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Moves: ${gameState.moves}',
                style: const TextStyle(color: Colors.white),
              ),
              // Show time remaining for Time Attack mode
              if (gameState.isTimedMode) ...[              
                const SizedBox(height: 8),
                Text(
                  'Time remaining: ${gameState.remainingTimeSeconds} seconds',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeonButton(
                    text: 'RETRY',
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameState.resetBoard();
                      _winAnimationController.reset();
                    },
                    width: 100,
                    height: 40,
                  ),
                  NeonButton(
                    text: 'NEXT',
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameState.nextLevel();
                      _winAnimationController.reset();
                      _loadLevel();
                    },
                    width: 100,
                    height: 40,
                    color: const Color(0xFF9D4EDD),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showFailureDialog() {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Play failure sound
    AudioManager().playSound('error');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.timer_off,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'TIME\'S UP!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completed ${gameState.connections.length} connections',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeonButton(
                    text: 'RETRY',
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameState.resetBoard();
                    },
                    width: 100,
                    height: 40,
                    color: Colors.redAccent,
                  ),
                  NeonButton(
                    text: 'EXIT',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Return to level select
                    },
                    width: 100,
                    height: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Level ${gameState.currentLevel}'),
        actions: [
          // Show pause/resume button for time attack mode
          if (gameState.isTimedMode)
            IconButton(
              icon: Icon(gameState.status == GameStatus.paused 
                  ? Icons.play_arrow 
                  : Icons.pause),
              tooltip: gameState.status == GameStatus.paused 
                  ? 'Resume game' 
                  : 'Pause game',
              onPressed: () {
                AudioManager().playSound('click');
                if (gameState.status == GameStatus.paused) {
                  gameState.resumeGame();
                } else if (gameState.status == GameStatus.playing) {
                  gameState.pauseGame();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              AudioManager().playSound('click');
              gameState.resetBoard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo last action',
            onPressed: gameState.actionHistory.isEmpty ? null : _undoLastMove,
            color: gameState.actionHistory.isEmpty ? Colors.grey : const Color(0xFF00FFFF),
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundGrid(),
          
          if (_isLevelLoaded)
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Moves counter
                            Row(
                              children: [
                                const Icon(
                                  Icons.swap_calls, 
                                  size: 16, 
                                  color: Colors.white70
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Moves: ${gameState.moves}',
                                  style: const TextStyle(
                                    color: Colors.white70, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            
                            // Game mode indicator
                            Row(
                              children: [
                                Icon(
                                  gameState.gameMode.icon, 
                                  size: 16, 
                                  color: gameState.gameMode.color
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  gameState.currentGameModeName,
                                  style: TextStyle(
                                    color: gameState.gameMode.color,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        // Show countdown timer for Time Attack mode
                        if (gameState.isTimedMode) ...[                        
                          const SizedBox(height: 12),
                          Center(
                            child: CountdownTimer(
                              remainingSeconds: gameState.remainingTimeSeconds,
                              isActive: gameState.status == GameStatus.playing,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _winAnimationController,
                        builder: (context, child) {
                          final scale = 1.0 + (_winAnimationController.value * 0.05 * 
                            (1 - _winAnimationController.value * 2).abs());
                          
                          return Transform.scale(
                            scale: scale,
                            child: GameBoard(
                              key: _boardKey,
                              onConnectionAdded: _onConnectionAdded,
                              onConnectionRemoved: _onConnectionRemoved,
                              onConnectionComplete: _checkWinCondition,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFFF)),
              ),
            ),
        ],
      ),
    );
  }
}
