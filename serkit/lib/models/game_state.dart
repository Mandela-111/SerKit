import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'node.dart';
import 'connection.dart';
import 'game_mode.dart';
import '../utils/statistics_manager.dart';

/// GameStatus enum to track different game states
enum GameStatus {
  playing,
  paused,
  won,
  failed,
}

/// ActionType enum to track different game actions for undo functionality
enum ActionType {
  addConnection,
  removeConnection,
  reset,
}

/// GameAction class to store information about game actions for undo functionality
class GameAction {
  final ActionType type;
  final Connection? connection;
  final List<Connection>? savedConnections;
  
  GameAction({
    required this.type,
    this.connection,
    this.savedConnections,
  });
}

/// GameState class that manages the entire game state
/// Uses ChangeNotifier to notify listeners when state changes
class GameState extends ChangeNotifier {
  List<List<Node>> board = [];
  List<Connection> connections = [];
  GameStatus status = GameStatus.playing;
  int currentLevel = 1;
  int moves = 0;
  int totalLevelsCompleted = 0;
  
  // Game mode properties
  GameModeType _gameModeType = GameModeType.classic;
  GameMode get gameMode => GameMode.fromType(_gameModeType);
  String get currentGameModeName => gameMode.name;
  
  // Time tracking
  Duration timeElapsed = Duration.zero;
  int _remainingTimeSeconds = 0;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  Timer? _gameTimer;
  bool get isTimedMode => _gameModeType == GameModeType.timeAttack;
  
  // Move history for undo functionality
  List<Connection> moveHistory = [];
  List<GameAction> actionHistory = [];
  int maxUndoSteps = 20;
  
  // Temporary variables for tracking ongoing connections
  Node? activeNode;
  bool isDragging = false;
  
  GameState() {
    _loadGameState();
  }
  
  @override
  void dispose() {
    _stopGameTimer();
    super.dispose();
  }

  /// Load saved game state from SharedPreferences
  Future<void> _loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentLevel = prefs.getInt('currentLevel') ?? 1;
      totalLevelsCompleted = prefs.getInt('totalLevelsCompleted') ?? 0;
      
      final savedGameMode = prefs.getString('gameModeType') ?? 'classic';
      _gameModeType = GameMode.typeFromString(savedGameMode);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading game state: $e');
      }
    }
  }

  /// Save current game state to SharedPreferences
  Future<void> saveGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentLevel', currentLevel);
      await prefs.setInt('totalLevelsCompleted', totalLevelsCompleted);
      await prefs.setString('gameModeType', GameMode.typeToString(_gameModeType));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving game state: $e');
      }
    }
  }

  /// Initialize the game board for a specific level
  void initializeBoard(List<List<Node>> newBoard) {
    board = newBoard;
    connections = [];
    moves = 0;
    status = GameStatus.playing;
    timeElapsed = Duration.zero;
    
    // Start the timer for time attack mode
    _stopGameTimer(); // Stop any existing timer
    
    if (isTimedMode) {
      // Set initial time from game mode settings
      _remainingTimeSeconds = gameMode.settings['initialTimeSeconds'] as int;
      _startGameTimer();
    }
    
    notifyListeners();
  }

  /// Add a connection between two nodes
  void addConnection(Connection connection) {
    connections.add(connection);
    moves++;
    
    // Record action in history
    actionHistory.add(GameAction(type: ActionType.addConnection, connection: connection));
    _trimHistory();
    
    // Update node states
    final startNode = connection.startNode;
    final endNode = connection.endNode;
    startNode.isConnected = true;
    endNode.isConnected = true;
    
    // Update stats
    StatisticsManager().updateConnectionsMade(1);
    
    // Add bonus time in time attack mode
    if (isTimedMode) {
      final timeBonus = gameMode.settings['timePerConnectionBonus'] as int;
      _remainingTimeSeconds += timeBonus;
    }
    
    checkWinCondition();
    notifyListeners();
  }

  /// Remove the last connection (manual removal, not undo)
  void removeLastConnection() {
    if (connections.isNotEmpty) {
      final lastConnection = connections.removeLast();
      
      // Record action in history
      actionHistory.add(GameAction(type: ActionType.removeConnection, connection: lastConnection));
      _trimHistory();
      
      _updateConnectionStatus(lastConnection);
      
      // Update stats
      StatisticsManager().updateConnectionsRemoved(1);
      
      notifyListeners();
    }
  }
  
  /// Undo the last action
  bool undo() {
    if (actionHistory.isEmpty) return false;
    
    final lastAction = actionHistory.removeLast();
    
    switch (lastAction.type) {
      case ActionType.addConnection:
        // Undo an add by removing the connection
        final connectionToRemove = lastAction.connection!;
        connections.removeWhere((conn) => 
          conn.startNode == connectionToRemove.startNode && 
          conn.endNode == connectionToRemove.endNode);
        
        _updateConnectionStatus(connectionToRemove);
        break;
        
      case ActionType.removeConnection:
        // Undo a removal by re-adding the connection
        final connectionToAdd = lastAction.connection!;
        connections.add(connectionToAdd);
        connectionToAdd.startNode.isConnected = true;
        connectionToAdd.endNode.isConnected = true;
        break;
        
      case ActionType.reset:
        // Undo a reset by restoring previous connections
        if (lastAction.savedConnections != null) {
          connections = List.from(lastAction.savedConnections!);
          // Restore connection status for all nodes
          for (final connection in connections) {
            connection.startNode.isConnected = true;
            connection.endNode.isConnected = true;
          }
        }
        break;
    }
    
    // Update statistics
    StatisticsManager().updateUndoActions(1);
    
    notifyListeners();
    return true;
  }
  
  /// Update connection status for nodes after connection changes
  void _updateConnectionStatus(Connection connection) {
    final isStartNodeInOtherConnection = connections.any(
      (conn) => conn.startNode == connection.startNode || conn.endNode == connection.startNode
    );
    
    final isEndNodeInOtherConnection = connections.any(
      (conn) => conn.startNode == connection.endNode || conn.endNode == connection.endNode
    );
    
    if (!isStartNodeInOtherConnection) {
      connection.startNode.isConnected = false;
    }
    
    if (!isEndNodeInOtherConnection) {
      connection.endNode.isConnected = false;
    }
  }
  
  /// Keep history within size limits
  void _trimHistory() {
    if (actionHistory.length > maxUndoSteps) {
      actionHistory.removeAt(0);
    }
  }

  /// Remove all connections and reset the board
  void resetBoard() {
    // Save current connections for undo
    final savedConnections = List<Connection>.from(connections);
    
    // Record action in history
    actionHistory.add(GameAction(
      type: ActionType.reset,
      savedConnections: savedConnections
    ));
    _trimHistory();
    
    for (final row in board) {
      for (final node in row) {
        node.isConnected = false;
      }
    }
    connections = [];
    moves = 0;
    status = GameStatus.playing;
    
    // Update statistics
    StatisticsManager().updateBoardResets(1);
    
    notifyListeners();
  }

  /// Check if all required connections are made to win the level
  void checkWinCondition() {
    // Check if all nodes are connected in a valid circuit
    final allNodesConnected = board.every((row) => 
      row.every((node) => !node.isRequired || node.isConnected));
    
    if (allNodesConnected) {
      status = GameStatus.won;
      totalLevelsCompleted++;
      
      // Stop timer and add bonus time if in time attack mode
      if (isTimedMode) {
        _stopGameTimer();
        final timeBonus = gameMode.settings['timePerLevelBonus'] as int;
        _remainingTimeSeconds += timeBonus;
      }
      
      saveGameState();
    }
  }

  /// Move to the next level
  void nextLevel() {
    currentLevel++;
    saveGameState();
    resetBoard();
  }
  
  /// Set the game mode
  void setGameMode(GameModeType type) {
    if (_gameModeType != type) {
      _gameModeType = type;
      saveGameState();
    }
  }
  
  /// Start the game timer for timed modes
  void _startGameTimer() {
    if (!isTimedMode) return;
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeSeconds > 0) {
        _remainingTimeSeconds--;
        notifyListeners();
      } else {
        // Time's up
        _stopGameTimer();
        status = GameStatus.failed;
        notifyListeners();
      }
    });
  }
  
  /// Stop the game timer
  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }
  
  /// Pause the game
  void pauseGame() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
      _stopGameTimer();
      notifyListeners();
    }
  }
  
  /// Resume the game
  void resumeGame() {
    if (status == GameStatus.paused) {
      status = GameStatus.playing;
      if (isTimedMode) {
        _startGameTimer();
      }
      notifyListeners();
    }
  }

  /// Start tracking an active node for connection
  void setActiveNode(Node node) {
    activeNode = node;
    isDragging = true;
    notifyListeners();
  }

  /// Clear the active node tracking
  void clearActiveNode() {
    activeNode = null;
    isDragging = false;
    notifyListeners();
  }

  /// Check if a connection between two nodes is valid
  bool isValidConnection(Node start, Node end) {
    // Nodes must be different
    if (start == end) return false;
    
    // Check if connection already exists
    final connectionExists = connections.any(
      (conn) => (conn.startNode == start && conn.endNode == end) || 
                (conn.startNode == end && conn.endNode == start)
    );
    if (connectionExists) return false;
    
    // Check if nodes are adjacent (depends on game rules)
    // For now, just check if they're in adjacent positions
    final startRow = start.row;
    final startCol = start.col;
    final endRow = end.row;
    final endCol = end.col;
    
    final rowDiff = (startRow - endRow).abs();
    final colDiff = (startCol - endCol).abs();
    
    return (rowDiff <= 1 && colDiff <= 1) && (rowDiff + colDiff > 0);
  }
}
