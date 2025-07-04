import 'package:flutter_test/flutter_test.dart';
import 'package:serkit/models/game_state.dart';
import 'package:serkit/models/node.dart';
import 'package:serkit/models/connection.dart';

void main() {
  group('GameState Tests', () {
    late GameState gameState;
    
    setUp(() {
      gameState = GameState();
      
      // Create a simple test board
      final board = List.generate(
        4,
        (i) => List.generate(
          4,
          (j) => Node(
            row: i,
            col: j,
            type: NodeType.regular,
            isRequired: false,
          ),
        ),
      );
      
      // Set start, end, and junction nodes
      board[0][0] = Node(
        row: 0,
        col: 0,
        type: NodeType.start,
        isRequired: true,
      );
      
      board[2][2] = Node(
        row: 2,
        col: 2,
        type: NodeType.junction,
        isRequired: true,
      );
      
      board[3][3] = Node(
        row: 3,
        col: 3,
        type: NodeType.end,
        isRequired: true,
      );
      
      gameState.initializeBoard(board);
    });
    
    test('Board initialization', () {
      expect(gameState.board.length, 4);
      expect(gameState.board[0].length, 4);
      expect(gameState.board[0][0].type, NodeType.start);
      expect(gameState.board[3][3].type, NodeType.end);
      expect(gameState.connections.isEmpty, true);
      expect(gameState.moves, 0);
      expect(gameState.status, GameStatus.playing);
    });
    
    test('Valid connections', () {
      // Test adjacent nodes (valid)
      expect(gameState.isValidConnection(gameState.board[0][0], gameState.board[0][1]), true);
      expect(gameState.isValidConnection(gameState.board[0][0], gameState.board[1][1]), true);
      
      // Test non-adjacent nodes (invalid)
      expect(gameState.isValidConnection(gameState.board[0][0], gameState.board[2][2]), false);
      expect(gameState.isValidConnection(gameState.board[0][0], gameState.board[3][3]), false);
      
      // Test same node (invalid)
      expect(gameState.isValidConnection(gameState.board[0][0], gameState.board[0][0]), false);
    });
    
    test('Adding connections', () {
      final startNode = gameState.board[0][0];
      final middleNode = gameState.board[0][1];
      
      // Add a connection
      gameState.addConnection(Connection(
        startNode: startNode,
        endNode: middleNode,
      ));
      
      expect(gameState.connections.length, 1);
      expect(gameState.moves, 1);
      expect(startNode.isConnected, true);
      expect(middleNode.isConnected, true);
    });
    
    test('Removing connections', () {
      final startNode = gameState.board[0][0];
      final middleNode = gameState.board[0][1];
      
      // Add a connection
      gameState.addConnection(Connection(
        startNode: startNode,
        endNode: middleNode,
      ));
      
      // Remove the connection
      gameState.removeLastConnection();
      
      expect(gameState.connections.isEmpty, true);
      expect(startNode.isConnected, false);
      expect(middleNode.isConnected, false);
    });
    
    test('Win condition', () {
      // Create a path from start to end
      final start = gameState.board[0][0];
      final junction = gameState.board[2][2];
      final end = gameState.board[3][3];
      
      // We need to add intermediate nodes to create a valid path
      final node1 = gameState.board[1][1];
      final node2 = gameState.board[2][3];
      
      // Path: start -> node1 -> junction -> node2 -> end
      gameState.addConnection(Connection(startNode: start, endNode: node1));
      gameState.addConnection(Connection(startNode: node1, endNode: junction));
      gameState.addConnection(Connection(startNode: junction, endNode: node2));
      gameState.addConnection(Connection(startNode: node2, endNode: end));
      
      // Check the win condition
      gameState.checkWinCondition();
      
      expect(gameState.status, GameStatus.won);
    });
    
    test('Resetting board', () {
      // Add some connections
      final start = gameState.board[0][0];
      final node1 = gameState.board[1][1];
      
      gameState.addConnection(Connection(startNode: start, endNode: node1));
      
      // Reset the board
      gameState.resetBoard();
      
      expect(gameState.connections.isEmpty, true);
      expect(gameState.moves, 0);
      expect(start.isConnected, false);
      expect(node1.isConnected, false);
    });
  });
}
