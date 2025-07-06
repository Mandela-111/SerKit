import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/node.dart';
import '../models/connection.dart';
import 'node_widget.dart';
import 'connection_animation.dart';

class GameBoard extends StatefulWidget {
  final VoidCallback? onConnectionComplete;
  final VoidCallback? onConnectionAdded;
  final VoidCallback? onConnectionRemoved;

  const GameBoard({
    super.key,
    this.onConnectionComplete,
    this.onConnectionAdded,
    this.onConnectionRemoved,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  /// Track current pointer position during drag
  Offset? _currentPointerPosition;
  
  /// Size of each node in the grid
  double _nodeSize = 60.0;
  
  /// Track newly added connections for animations
  Map<Connection, AnimationController> _connectionAnimations = {};
  
  @override
  void dispose() {
    // Clean up all animation controllers
    for (final controller in _connectionAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final size = MediaQuery.of(context).size;
    
    // Calculate appropriate node size based on screen and board dimensions
    if (gameState.board.isNotEmpty) {
      final boardHeight = gameState.board.length;
      final boardWidth = gameState.board.isNotEmpty ? gameState.board[0].length : 0;
      
      if (boardWidth > 0 && boardHeight > 0) {
        final maxWidth = size.width * 0.9; // 90% of screen width
        final maxHeight = size.height * 0.6; // 60% of screen height
        
        final widthPerNode = maxWidth / boardWidth;
        final heightPerNode = maxHeight / boardHeight;
        
        // Choose the smaller of the two to ensure board fits in both dimensions
        _nodeSize = widthPerNode < heightPerNode ? widthPerNode : heightPerNode;
      }
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: _nodeSize * (gameState.board.isNotEmpty ? gameState.board[0].length : 0),
          height: _nodeSize * gameState.board.length,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Draw grid lines
              CustomPaint(
                size: Size(
                  _nodeSize * (gameState.board.isNotEmpty ? gameState.board[0].length : 0),
                  _nodeSize * gameState.board.length,
                ),
                painter: GridPainter(_nodeSize),
              ),
              
              // Draw existing connections with animations
              Stack(
                children: [
                  // Static connections
                  CustomPaint(
                    size: Size(
                      _nodeSize * (gameState.board.isNotEmpty ? gameState.board[0].length : 0),
                      _nodeSize * gameState.board.length,
                    ),
                    painter: ConnectionPainter(
                      // Only draw connections without animations
                      gameState.connections.where(
                        (conn) => !_connectionAnimations.containsKey(conn)
                      ).toList(),
                      _nodeSize,
                    ),
                  ),
                  
                  // Animated connections
                  ...gameState.connections
                    .where((conn) => _connectionAnimations.containsKey(conn))
                    .map((conn) => ConnectionAnimation(
                      connection: conn,
                      boardSize: _nodeSize * (gameState.board.isNotEmpty ? gameState.board[0].length : 0),
                      nodeSize: _nodeSize,
                    ))
                    .toList(),
                ],
              ),
              
              
              // Draw temporary connection during dragging
              if (gameState.isDragging && gameState.activeNode != null && _currentPointerPosition != null)
                CustomPaint(
                  size: Size(
                    _nodeSize * (gameState.board.isNotEmpty ? gameState.board[0].length : 0),
                    _nodeSize * gameState.board.length,
                  ),
                  painter: TempConnectionPainter(
                    gameState.activeNode!,
                    _currentPointerPosition!,
                    _nodeSize,
                  ),
                ),
              
              // Place nodes
              for (int rowIndex = 0; rowIndex < gameState.board.length; rowIndex++)
                for (int colIndex = 0; colIndex < gameState.board[rowIndex].length; colIndex++)
                  Positioned(
                    left: colIndex * _nodeSize,
                    top: rowIndex * _nodeSize,
                    child: GestureDetector(
                      onPanStart: (details) {
                        final node = gameState.board[rowIndex][colIndex];
                        gameState.setActiveNode(node);
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _currentPointerPosition = details.localPosition;
                        });
                      },
                      onPanEnd: (_) => _handlePanEnd(rowIndex, colIndex),
                      child: NodeWidget(
                        node: gameState.board[rowIndex][colIndex],
                        size: _nodeSize,
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
  
  void _handlePanEnd(int startRow, int startCol) {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    if (!gameState.isDragging || _currentPointerPosition == null) {
      gameState.clearActiveNode();
      setState(() {
        _currentPointerPosition = null;
      });
      return;
    }
    
    // Calculate which node is at the end position
    final endCol = (_currentPointerPosition!.dx / _nodeSize).floor();
    final endRow = (_currentPointerPosition!.dy / _nodeSize).floor();
    
    // Validate that we're within board bounds
    if (endRow >= 0 && endRow < gameState.board.length &&
        endCol >= 0 && endCol < gameState.board[0].length) {
      
      final startNode = gameState.board[startRow][startCol];
      final endNode = gameState.board[endRow][endCol];
      
      // Check if connection is valid
      if (gameState.isValidConnection(startNode, endNode)) {
        // Create new connection
        final connection = Connection(
          startNode: startNode,
          endNode: endNode,
        );
        
        // Add the connection to game state
        gameState.addConnection(connection);
        
        // Create animation controller for the new connection
        final animController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        );
        
        setState(() {
          _connectionAnimations[connection] = animController;
        });
        
        // Remove from animations map after animation completes
        animController.forward().then((_) {
          if (mounted) {
            setState(() {
              _connectionAnimations.remove(connection);
            });
            animController.dispose();
          }
        });
        
        // Add particle burst at connection point
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            // Rebuild to ensure connection is shown properly
            setState(() {});
          }
        });
        
        // Call the callback for connection added
        widget.onConnectionAdded?.call();
        
        // Call the callback for win condition check
        widget.onConnectionComplete?.call();
      }
    }
    
    // Clean up
    gameState.clearActiveNode();
    setState(() {
      _currentPointerPosition = null;
    });
  }
}

/// Custom painter for drawing grid lines
class GridPainter extends CustomPainter {
  final double gridSize;
  
  GridPainter(this.gridSize);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 0.5;
    
    // Draw horizontal grid lines
    for (int i = 0; i <= size.height / gridSize; i++) {
      canvas.drawLine(
        Offset(0, i * gridSize),
        Offset(size.width, i * gridSize),
        paint,
      );
    }
    
    // Draw vertical grid lines
    for (int i = 0; i <= size.width / gridSize; i++) {
      canvas.drawLine(
        Offset(i * gridSize, 0),
        Offset(i * gridSize, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for drawing existing connections
class ConnectionPainter extends CustomPainter {
  final List<Connection> connections;
  final double nodeSize;
  
  ConnectionPainter(this.connections, this.nodeSize);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in connections) {
      final start = connection.getStartOffset(nodeSize);
      final end = connection.getEndOffset(nodeSize);
      
      // Create a glowing effect
      for (double i = 3; i > 0; i--) {
        final paint = Paint()
          ..color = connection.color.withOpacity(0.1 * i)
          ..strokeWidth = connection.thickness + (4 - i) * 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        
        canvas.drawLine(start, end, paint);
      }
      
      // Draw the main line
      final paint = Paint()
        ..color = connection.color
        ..strokeWidth = connection.thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(start, end, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for drawing temporary connection during dragging
class TempConnectionPainter extends CustomPainter {
  final Node startNode;
  final Offset endPosition;
  final double nodeSize;
  
  TempConnectionPainter(this.startNode, this.endPosition, this.nodeSize);
  
  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(
      (startNode.col * nodeSize) + (nodeSize / 2),
      (startNode.row * nodeSize) + (nodeSize / 2),
    );
    
    // Create a more interesting cyberpunk line effect with multiple segments
    final dx = endPosition.dx - start.dx;
    final dy = endPosition.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Only draw if there's distance between nodes
    if (distance > 0) {
      // Create dashed line effect
      final dashLength = distance / 15;
      final numDashes = (distance / dashLength).floor();
      final dashGap = 3.0;
      
      for (int i = 0; i < numDashes; i++) {
        final startFraction = i * dashLength / distance;
        final endFraction = (i * dashLength + dashLength - dashGap) / distance;
        
        final dashStart = Offset(
          start.dx + dx * startFraction,
          start.dy + dy * startFraction,
        );
        
        final dashEnd = Offset(
          start.dx + dx * endFraction,
          start.dy + dy * endFraction,
        );
        
        // Create a glowing effect
        for (double j = 3; j > 0; j--) {
          final paint = Paint()
            ..color = _getNodeColor(startNode.type).withOpacity(0.1 * j)
            ..strokeWidth = 3 + (4 - j) * 2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          
          canvas.drawLine(dashStart, dashEnd, paint);
        }
        
        // Draw the main line
        final paint = Paint()
          ..color = _getNodeColor(startNode.type)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        
        canvas.drawLine(dashStart, dashEnd, paint);
      }
      
      // Draw endpoint glow
      final glowPaint = Paint()
        ..color = _getNodeColor(startNode.type).withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(endPosition, 12, glowPaint);
      canvas.drawCircle(endPosition, 6, Paint()..color = _getNodeColor(startNode.type));
    }
  }
  
  Color _getNodeColor(NodeType type) {
    switch (type) {
      case NodeType.start:
        return const Color(0xFF00FFFF); // Cyan for start nodes
      case NodeType.end:
        return const Color(0xFFF72585); // Pink for end nodes
      case NodeType.junction:
        return const Color(0xFF9D4EDD); // Purple for junctions
      default:
        return const Color(0xFFFFFFFF); // White for regular nodes
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
