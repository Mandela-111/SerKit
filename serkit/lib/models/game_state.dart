import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'node.dart';
import 'connection.dart';

/// GameStatus enum to track different game states
enum GameStatus {
  playing,
  paused,
  won,
  failed,
}

/// GameState class that manages the entire game state
/// Uses ChangeNotifier to notify listeners when state changes
class GameState extends ChangeNotifier {
  List<List<Node>> board = [];
  List<Connection> connections = [];
  GameStatus status = GameStatus.playing;
  int currentLevel = 1;
  int moves = 0;
  Duration timeElapsed = Duration.zero;
  int totalLevelsCompleted = 0;
  String currentGameMode = 'Classic';
  
  // Temporary variables for tracking ongoing connections
  Node? activeNode;
  bool isDragging = false;
  
  GameState() {
    _loadGameState();
  }

  /// Load saved game state from SharedPreferences
  Future<void> _loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentLevel = prefs.getInt('currentLevel') ?? 1;
      totalLevelsCompleted = prefs.getInt('totalLevelsCompleted') ?? 0;
      currentGameMode = prefs.getString('currentGameMode') ?? 'Classic';
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
      await prefs.setString('currentGameMode', currentGameMode);
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
    notifyListeners();
  }

  /// Add a connection between two nodes
  void addConnection(Connection connection) {
    connections.add(connection);
    moves++;
    
    // Update node states
    final startNode = connection.startNode;
    final endNode = connection.endNode;
    startNode.isConnected = true;
    endNode.isConnected = true;
    
    checkWinCondition();
    notifyListeners();
  }

  /// Remove the last connection (undo)
  void removeLastConnection() {
    if (connections.isNotEmpty) {
      final lastConnection = connections.removeLast();
      
      // Update node states if needed
      final isStartNodeInOtherConnection = connections.any(
        (conn) => conn.startNode == lastConnection.startNode || conn.endNode == lastConnection.startNode
      );
      
      final isEndNodeInOtherConnection = connections.any(
        (conn) => conn.startNode == lastConnection.endNode || conn.endNode == lastConnection.endNode
      );
      
      if (!isStartNodeInOtherConnection) {
        lastConnection.startNode.isConnected = false;
      }
      
      if (!isEndNodeInOtherConnection) {
        lastConnection.endNode.isConnected = false;
      }
      
      notifyListeners();
    }
  }

  /// Remove all connections and reset the board
  void resetBoard() {
    for (final row in board) {
      for (final node in row) {
        node.isConnected = false;
      }
    }
    connections = [];
    moves = 0;
    status = GameStatus.playing;
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
      saveGameState();
    }
  }

  /// Move to the next level
  void nextLevel() {
    currentLevel++;
    saveGameState();
    resetBoard();
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
