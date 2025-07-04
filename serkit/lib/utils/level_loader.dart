import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/node.dart';
import '../models/level.dart';

/// Utility class responsible for loading level data
class LevelLoader {
  /// Load a level from assets or generate dynamically
  static Future<List<List<Node>>> loadLevel(int levelNumber) async {
    try {
      // Try to load from JSON file first
      final level = await loadLevelFromJson(levelNumber);
      if (level != null) {
        return _convertLevelToBoard(level);
      }
    } catch (e) {
      print('Failed to load level from JSON: $e');
    }
    
    // Fallback to generated level if JSON loading fails
    return _generateLevel(levelNumber);
  }
  
  /// Load a level from a JSON file
  static Future<Level?> loadLevelFromJson(int levelNumber) async {
    try {
      final jsonString = await rootBundle.loadString('assets/levels/level_$levelNumber.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return Level.fromJson(jsonData);
    } catch (e) {
      print('Error loading level $levelNumber JSON: $e');
      return null;
    }
  }
  
  /// Convert a Level object to a board of nodes
  static List<List<Node>> _convertLevelToBoard(Level level) {
    final width = level.gridSize.width;
    final height = level.gridSize.height;
    
    // Create empty board
    List<List<Node>> board = List.generate(
      height,
      (i) => List.generate(
        width,
        (j) => Node(
          row: i,
          col: j,
          type: NodeType.regular,
          isRequired: false,
        ),
      ),
    );
    
    // Place nodes from level data
    for (final nodeData in level.nodes) {
      final NodeType type = _convertNodeType(nodeData.type);
      board[nodeData.position.y][nodeData.position.x] = Node(
        row: nodeData.position.y,
        col: nodeData.position.x,
        type: type,
        isRequired: true,
      );
    }
    
    return board;
  }
  
  /// Convert node type string from JSON to NodeType enum
  static NodeType _convertNodeType(String typeStr) {
    switch (typeStr) {
      case 'source':
        return NodeType.start;
      case 'target':
        return NodeType.end;
      case 'processor':
        return NodeType.junction;
      default:
        return NodeType.regular;
    }
  }
  
  /// Generate a level programmatically based on level number
  static List<List<Node>> _generateLevel(int levelNumber) {
    // Determine board size based on level
    int rows = 4;
    int cols = 4;
    
    // Increase board size for more advanced levels
    if (levelNumber > 5) {
      rows = 5;
    }
    if (levelNumber > 10) {
      rows = 6;
      cols = 6;
    }
    if (levelNumber > 15) {
      rows = 7;
      cols = 6;
    }
    
    // Create empty board
    List<List<Node>> board = List.generate(
      rows,
      (i) => List.generate(
        cols,
        (j) => Node(
          row: i,
          col: j,
          type: NodeType.regular,
          isRequired: false,
        ),
      ),
    );
    
    // Simple level (linear path)
    if (levelNumber <= 3) {
      _generateSimpleLevel(board);
    }
    // Medium level (branching paths)
    else if (levelNumber <= 10) {
      _generateMediumLevel(board, levelNumber);
    }
    // Hard level (complex patterns)
    else {
      _generateHardLevel(board, levelNumber);
    }
    
    return board;
  }
  
  /// Generate a simple level with a linear path
  static void _generateSimpleLevel(List<List<Node>> board) {
    final rows = board.length;
    final cols = board[0].length;
    
    // Place start node
    board[0][0] = Node(
      row: 0,
      col: 0,
      type: NodeType.start,
    );
    
    // Place end node
    board[rows - 1][cols - 1] = Node(
      row: rows - 1,
      col: cols - 1,
      type: NodeType.end,
    );
    
    // Place a few junction nodes forming a path
    int midRow = rows ~/ 2;
    int midCol = cols ~/ 2;
    
    board[midRow][0] = Node(
      row: midRow,
      col: 0,
      type: NodeType.junction,
    );
    
    board[midRow][midCol] = Node(
      row: midRow,
      col: midCol,
      type: NodeType.junction,
    );
    
    board[rows - 1][midCol] = Node(
      row: rows - 1,
      col: midCol,
      type: NodeType.junction,
    );
    
    // Mark path nodes as required
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (board[i][j].type != NodeType.regular) {
          board[i][j] = board[i][j].copyWith(isRequired: true);
        }
      }
    }
  }
  
  /// Generate a medium complexity level with branching paths
  static void _generateMediumLevel(List<List<Node>> board, int levelNumber) {
    final rows = board.length;
    final cols = board[0].length;
    
    // Place start and end nodes
    board[0][0] = Node(
      row: 0,
      col: 0,
      type: NodeType.start,
      isRequired: true,
    );
    
    board[rows - 1][cols - 1] = Node(
      row: rows - 1,
      col: cols - 1,
      type: NodeType.end,
      isRequired: true,
    );
    
    // Add additional end point for higher levels
    if (levelNumber > 7) {
      board[0][cols - 1] = Node(
        row: 0,
        col: cols - 1,
        type: NodeType.end,
        isRequired: true,
      );
    }
    
    // Place junction nodes to create a more complex path
    List<List<int>> junctionPositions = [
      [rows ~/ 2, cols ~/ 2],
      [1, cols ~/ 2],
      [rows - 2, 1],
      [rows ~/ 2, cols - 2],
    ];
    
    for (List<int> pos in junctionPositions) {
      board[pos[0]][pos[1]] = Node(
        row: pos[0],
        col: pos[1],
        type: NodeType.junction,
        isRequired: true,
      );
    }
    
    // Add a few regular nodes that are required
    List<List<int>> requiredPositions = [
      [1, 1],
      [rows - 2, cols - 2],
    ];
    
    for (List<int> pos in requiredPositions) {
      board[pos[0]][pos[1]] = board[pos[0]][pos[1]].copyWith(isRequired: true);
    }
  }
  
  /// Generate a hard level with complex patterns
  static void _generateHardLevel(List<List<Node>> board, int levelNumber) {
    final rows = board.length;
    final cols = board[0].length;
    
    // Place start node in center
    int startRow = rows ~/ 2;
    int startCol = cols ~/ 2;
    
    board[startRow][startCol] = Node(
      row: startRow,
      col: startCol,
      type: NodeType.start,
      isRequired: true,
    );
    
    // Place multiple end nodes
    List<List<int>> endPositions = [
      [0, 0],
      [0, cols - 1],
      [rows - 1, 0],
      [rows - 1, cols - 1],
    ];
    
    // For super hard levels, only use a subset of ends
    int endCount = (levelNumber > 20) ? 3 : ((levelNumber > 15) ? 2 : 4);
    
    for (int i = 0; i < endCount; i++) {
      List<int> pos = endPositions[i];
      board[pos[0]][pos[1]] = Node(
        row: pos[0],
        col: pos[1],
        type: NodeType.end,
        isRequired: true,
      );
    }
    
    // Place junction nodes in a pattern
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        // Place junctions in a pattern
        if ((i + j) % 3 == 0 && 
            board[i][j].type == NodeType.regular &&
            (i != startRow || j != startCol)) {
          board[i][j] = Node(
            row: i,
            col: j,
            type: NodeType.junction,
            isRequired: true,
          );
        }
      }
    }
    
    // Add a few more required nodes
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        // Make some regular nodes required to increase complexity
        if ((i * j) % 7 == 1 && 
            board[i][j].type == NodeType.regular) {
          board[i][j] = board[i][j].copyWith(isRequired: true);
        }
      }
    }
  }
  
  /// Save level progress
  static Future<void> saveLevelProgress(int levelNumber, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_$levelNumber', stars);
  }
  
  /// Get level progress (number of stars)
  static Future<int> getLevelProgress(int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_$levelNumber') ?? 0;
  }
}
