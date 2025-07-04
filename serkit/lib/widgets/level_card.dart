import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isCompleted 
        ? const Color(0xFF9D4EDD) // Purple
        : isUnlocked 
            ? const Color(0xFF00FFFF) // Cyan 
            : Colors.grey;

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withOpacity(0.7),
            width: 2,
          ),
          boxShadow: isUnlocked 
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Level number
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$levelNumber',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      shadows: isUnlocked 
                          ? [
                              Shadow(
                                color: primaryColor.withOpacity(0.7),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            
            // Locked indicator
            if (!isUnlocked)
              Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.grey.withOpacity(0.7),
                  size: 40,
                ),
              ),
              
            // Completed indicator
            if (isCompleted)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9D4EDD),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF9D4EDD),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
              
            // Animation pattern for unlocked levels
            if (isUnlocked && !isCompleted)
              Positioned.fill(
                child: CustomPaint(
                  painter: CircuitPatternPainter(primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw circuit patterns on the level card
class CircuitPatternPainter extends CustomPainter {
  final Color color;
  
  CircuitPatternPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    // Draw simple circuit pattern
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.4, size.height * 0.2)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8);
      
    canvas.drawPath(path, paint);
    
    // Draw connection points
    final dotPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.2), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.8), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.8), 2, dotPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
