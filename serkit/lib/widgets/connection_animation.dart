import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/connection.dart';
import '../models/node.dart';
import 'circuit_particle.dart';

/// Widget that animates circuit connections with glowing lines and particle effects
class ConnectionAnimation extends StatefulWidget {
  final Connection connection;
  final double boardSize;
  final double nodeSize;
  final bool showParticles;
  
  const ConnectionAnimation({
    Key? key,
    required this.connection,
    required this.boardSize,
    required this.nodeSize,
    this.showParticles = true,
  }) : super(key: key);

  @override
  State<ConnectionAnimation> createState() => _ConnectionAnimationState();
}

class _ConnectionAnimationState extends State<ConnectionAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _showingParticles = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.0, end: 5.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 2.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_controller);
    
    _controller.forward();
    
    // Show particles after a short delay to allow connection line to appear first
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted && widget.showParticles) {
        setState(() {
          _showingParticles = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getNodePosition(Node node) {
    final cellSize = widget.boardSize / 8; // Assuming 8x8 grid
    final xPos = (node.col * cellSize) + (cellSize / 2);
    final yPos = (node.row * cellSize) + (cellSize / 2);
    return Offset(xPos, yPos);
  }
  
  Color _getConnectionColor(NodeType type) {
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
  Widget build(BuildContext context) {
    final startPos = _getNodePosition(widget.connection.startNode);
    final endPos = _getNodePosition(widget.connection.endNode);
    
    // Color based on start node type
    final connectionColor = _getConnectionColor(widget.connection.startNode.type);
    
    return Stack(
      children: [
        // The connection line with glow effect
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.boardSize, widget.boardSize),
              painter: _ConnectionPainter(
                start: startPos,
                end: endPos,
                nodeRadius: widget.nodeSize / 2,
                color: connectionColor,
                glowRadius: _glowAnimation.value,
              ),
            );
          },
        ),
        
        // Particle effects along the connection
        if (_showingParticles)
          CircuitParticleEffect(
            startPoint: startPos,
            endPoint: endPos,
            color: connectionColor,
            duration: const Duration(milliseconds: 1200),
          ),
      ],
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double nodeRadius;
  final Color color;
  final double glowRadius;
  
  _ConnectionPainter({
    required this.start,
    required this.end,
    required this.nodeRadius,
    required this.color,
    required this.glowRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate connection line vector
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Only draw if there's distance between nodes
    if (distance > 0) {
      // Unit vector
      final unitDx = dx / distance;
      final unitDy = dy / distance;
      
      // Start and end points (adjusted to start from node edges)
      final adjustedStart = Offset(
        start.dx + unitDx * nodeRadius,
        start.dy + unitDy * nodeRadius,
      );
      
      final adjustedEnd = Offset(
        end.dx - unitDx * nodeRadius,
        end.dy - unitDy * nodeRadius,
      );
      
      // Base line
      final basePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(adjustedStart, adjustedEnd, basePaint);
      
      // Glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = glowRadius
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(adjustedStart, adjustedEnd, glowPaint);
    }
  }
  
  @override
  bool shouldRepaint(_ConnectionPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.glowRadius != glowRadius ||
        oldDelegate.color != color;
  }
  
  double sqrt(double value) => value <= 0 ? 0 : math.sqrt(value);
}

