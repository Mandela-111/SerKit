import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget that displays a glowing ripple effect when an undo action is performed
class UndoEffect extends StatefulWidget {
  final Offset position;
  final Color color;
  final double size;
  
  const UndoEffect({
    Key? key,
    required this.position,
    this.color = const Color(0xFFFF5555),
    this.size = 100.0,
  }) : super(key: key);

  @override
  State<UndoEffect> createState() => _UndoEffectState();
}

class _UndoEffectState extends State<UndoEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _sizeAnimation = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Auto-start and remove when done
    _controller.forward().then((_) {
      if (mounted) {
        // Remove this widget when animation is done
        Navigator.of(context).pop();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _UndoEffectPainter(
            position: widget.position,
            color: widget.color,
            progress: _sizeAnimation.value,
            opacity: _opacityAnimation.value,
          ),
        );
      },
    );
  }
}

class _UndoEffectPainter extends CustomPainter {
  final Offset position;
  final Color color;
  final double progress;
  final double opacity;
  
  _UndoEffectPainter({
    required this.position,
    required this.color,
    required this.progress,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Main ripple
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * (1.0 - progress * 0.5);
    
    final radius = size.width * 0.5 * progress;
    canvas.drawCircle(position, radius, paint);
    
    // Inner glow
    final glowPaint = Paint()
      ..color = color.withOpacity(opacity * 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, radius * 0.3, glowPaint);
    
    // Draw some "undo" arrows around the circle
    if (progress > 0.3) {
      _drawUndoArrows(canvas, position, radius, opacity);
    }
  }
  
  void _drawUndoArrows(Canvas canvas, Offset center, double radius, double opacity) {
    final arrowPaint = Paint()
      ..color = color.withOpacity(opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    // Draw 3 arrows around the circle
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) + (progress * math.pi);
      final startPoint = Offset(
        center.dx + radius * 0.6 * math.cos(angle),
        center.dy + radius * 0.6 * math.sin(angle),
      );
      
      // Calculate the arc path for a curved arrow
      final rect = Rect.fromCircle(
        center: startPoint,
        radius: radius * 0.3,
      );
      
      final path = Path()
        ..moveTo(startPoint.dx, startPoint.dy)
        ..addArc(rect, angle + math.pi / 2, -math.pi);
      
      // Add arrowhead
      final arrowEnd = Offset(
        startPoint.dx + radius * 0.3 * math.cos(angle - math.pi / 2),
        startPoint.dy + radius * 0.3 * math.sin(angle - math.pi / 2),
      );
      
      final arrowTip1 = Offset(
        arrowEnd.dx + 5 * math.cos(angle - math.pi / 4),
        arrowEnd.dy + 5 * math.sin(angle - math.pi / 4),
      );
      
      final arrowTip2 = Offset(
        arrowEnd.dx + 5 * math.cos(angle - 3 * math.pi / 4),
        arrowEnd.dy + 5 * math.sin(angle - 3 * math.pi / 4),
      );
      
      canvas.drawPath(path, arrowPaint);
      canvas.drawLine(arrowEnd, arrowTip1, arrowPaint);
      canvas.drawLine(arrowEnd, arrowTip2, arrowPaint);
    }
  }
  
  @override
  bool shouldRepaint(_UndoEffectPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.opacity != opacity;
  }
}
