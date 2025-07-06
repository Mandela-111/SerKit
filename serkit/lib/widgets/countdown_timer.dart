import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final bool isActive;
  
  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Format time as mm:ss
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    // Determine color based on remaining time
    Color timerColor;
    if (remainingSeconds > 30) {
      timerColor = Colors.green;
    } else if (remainingSeconds > 15) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }
    
    // Pulse animation for low time
    final shouldPulse = remainingSeconds <= 10 && isActive;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: shouldPulse 
            ? timerColor.withOpacity(0.3)
            : Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: timerColor,
          width: 1.5,
        ),
        boxShadow: shouldPulse
            ? [
                BoxShadow(
                  color: timerColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: timerColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            formattedTime,
            style: TextStyle(
              color: timerColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
