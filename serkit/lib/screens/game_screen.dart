import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/game_board.dart';
import '../utils/audio_manager.dart';
import '../widgets/background_grid.dart';
import '../widgets/neon_button.dart';
import '../utils/level_loader.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _winAnimationController;
  bool _isLevelLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _winAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadLevel();
    
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
    
    if (gameState.connections.isNotEmpty) {
      // Play click sound
      AudioManager().playSound('click');
      gameState.removeLastConnection();
    } else {
      // Play error sound if nothing to undo
      AudioManager().playSound('error');
    }
  }
  
  void _checkWinCondition() {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.status == GameStatus.won) {
      _winAnimationController.forward();
      
      // Play win sound
      AudioManager().playSound('win');
      
      // Show win dialog after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showWinDialog();
        }
      });
    }
  }
  
  void _showWinDialog() {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
        ),
        title: const Text(
          'Level Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF00FFFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Moves: ${gameState.moves}',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              AudioManager().playSound('click');
              gameState.resetBoard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: gameState.connections.isEmpty ? null : _undoLastMove,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Moves: ${gameState.moves}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Mode: ${gameState.currentGameMode}',
                          style: const TextStyle(color: Colors.white70),
                        ),
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
