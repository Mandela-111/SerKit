import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/background_grid.dart';
import '../utils/audio_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Play sound effect
    Timer(const Duration(milliseconds: 500), () {
      AudioManager().playSound('connect');
    });
    
    // Navigate to home screen after delay
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const BackgroundGrid(),
          
          // Centered content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00FFFF),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF00FFFF),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _buildLogo(),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Game title
                        const Text(
                          'SerKit',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FFFF),
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Color(0xFF00FFFF),
                                blurRadius: 15,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        const Text(
                          'CIRCUIT FLOW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Loading indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: const SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.black45,
                        color: Color(0xFF9D4EDD),
                        minHeight: 4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogo() {
    return CustomPaint(
      size: const Size(100, 100),
      painter: CircuitLogoPainter(),
    );
  }
}

class CircuitLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw a simple circuit pattern logo
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.7);
      
    canvas.drawPath(path, paint);
    
    // Draw connection points
    final dotPaint = Paint()
      ..color = const Color(0xFF9D4EDD)
      ..style = PaintingStyle.fill;
      
    // Starting node
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5), 6, dotPaint);
    
    // End node
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 6, dotPaint);
    
    // Junction nodes
    final junctionPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.3), 4, junctionPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.7), 4, junctionPaint);
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawPath(path, glowPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
