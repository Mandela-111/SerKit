import 'package:flutter/material.dart';

class BackgroundGrid extends StatelessWidget {
  final Color gridColor;
  final double gridSpacing;
  final double gridThickness;
  final bool showParticles;

  const BackgroundGrid({
    super.key,
    this.gridColor = const Color(0xFF00FFFF),
    this.gridSpacing = 40.0,
    this.gridThickness = 0.5,
    this.showParticles = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark background
        Container(
          color: Colors.black,
        ),
        
        // Grid lines
        CustomPaint(
          size: Size.infinite,
          painter: GridPainter(
            gridColor: gridColor,
            gridSpacing: gridSpacing,
            gridThickness: gridThickness,
          ),
        ),
        
        // Particles overlay (optional)
        if (showParticles)
          LayoutBuilder(
            builder: (context, constraints) {
              return ParticlesEffect(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                particleColor: gridColor,
              );
            },
          ),
        
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.5),
              radius: 1.5,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSpacing;
  final double gridThickness;

  GridPainter({
    required this.gridColor,
    required this.gridSpacing,
    required this.gridThickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.15)
      ..strokeWidth = gridThickness;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParticlesEffect extends StatefulWidget {
  final double width;
  final double height;
  final Color particleColor;

  const ParticlesEffect({
    super.key,
    required this.width,
    required this.height,
    required this.particleColor,
  });

  @override
  State<ParticlesEffect> createState() => _ParticlesEffectState();
}

class _ParticlesEffectState extends State<ParticlesEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    
    // Create particles
    _initializeParticles();
    
    // Set up animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _controller.addListener(() {
      for (final particle in _particles) {
        particle.update();
      }
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _initializeParticles() {
    // Create a sparse array of particles
    final int particleCount = (widget.width * widget.height) ~/ 40000;
    
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        x: widget.width * _random(),
        y: widget.height * _random(),
        size: 1.0 + _random() * 2.0,
        color: widget.particleColor,
        speedX: 0.1 * (_random() - 0.5),
        speedY: 0.1 * (_random() - 0.5),
        maxX: widget.width,
        maxY: widget.height,
      ));
    }
  }
  
  double _random() {
    return (DateTime.now().microsecondsSinceEpoch % 100000) / 100000;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: ParticlesPainter(
        particles: _particles,
        color: widget.particleColor,
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  Color color;
  double speedX;
  double speedY;
  double maxX;
  double maxY;
  double opacity = 0.0;
  double opacitySpeed = 0.01;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speedX,
    required this.speedY,
    required this.maxX,
    required this.maxY,
  });

  void update() {
    // Update position
    x += speedX;
    y += speedY;
    
    // Handle boundaries
    if (x < 0) x = maxX;
    if (x > maxX) x = 0;
    if (y < 0) y = maxY;
    if (y > maxY) y = 0;
    
    // Pulsing opacity effect
    opacity += opacitySpeed;
    if (opacity > 0.7 || opacity < 0.1) {
      opacitySpeed *= -1;
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  
  ParticlesPainter({
    required this.particles,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
