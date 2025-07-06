import 'dart:math';
import 'package:flutter/material.dart';

/// A particle that animates along circuit connections
class CircuitParticle {
  final Offset start;
  final Offset end;
  Offset position;
  final Color color;
  final double size;
  double progress = 0.0;
  final double speed;
  bool isDead = false;

  CircuitParticle({
    required this.start,
    required this.end,
    required this.color,
    this.size = 3.0,
    this.speed = 0.02,
  }) : position = start;

  void update() {
    progress += speed;
    if (progress >= 1.0) {
      isDead = true;
      progress = 1.0;
    }
    position = Offset.lerp(start, end, progress)!;
  }

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.3, 1.0))
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Draw the main particle
    canvas.drawCircle(position, size, paint);
    
    // Draw a glow effect
    paint.color = color.withOpacity((1.0 - progress).clamp(0.0, 0.3));
    canvas.drawCircle(position, size * 2.5, paint);
  }
}

/// Widget that renders circuit connection particle effects
class CircuitParticleEffect extends StatefulWidget {
  final Offset startPoint;
  final Offset endPoint;
  final Color color;
  final int particleCount;
  final Duration duration;
  
  const CircuitParticleEffect({
    Key? key,
    required this.startPoint,
    required this.endPoint,
    this.color = const Color(0xFF00FFFF),
    this.particleCount = 8,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<CircuitParticleEffect> createState() => _CircuitParticleEffectState();
}

class _CircuitParticleEffectState extends State<CircuitParticleEffect> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CircuitParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.addListener(_updateParticles);
    _createParticles();
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _createParticles() {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      // Create particles with slight variance in size and speed
      final variance = _random.nextDouble() * 0.01;
      
      _particles.add(CircuitParticle(
        start: widget.startPoint,
        end: widget.endPoint,
        color: widget.color,
        size: 2.0 + _random.nextDouble() * 2.0,
        speed: 0.01 + variance,
      ));
    }
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    for (final particle in _particles) {
      particle.update();
    }
    
    setState(() {});
    
    // Remove dead particles
    _particles.removeWhere((particle) => particle.isDead);
    
    // Stop animation when all particles are dead
    if (_particles.isEmpty && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ParticleEffectPainter(_particles),
    );
  }
}

class _ParticleEffectPainter extends CustomPainter {
  final List<CircuitParticle> particles;
  
  _ParticleEffectPainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.render(canvas);
    }
  }
  
  @override
  bool shouldRepaint(_ParticleEffectPainter oldDelegate) => true;
}
