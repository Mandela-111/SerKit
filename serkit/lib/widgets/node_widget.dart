import 'package:flutter/material.dart';
import '../models/node.dart';

class NodeWidget extends StatelessWidget {
  final Node node;
  final double size;

  const NodeWidget({
    super.key,
    required this.node,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate actual node circle size (smaller than the grid cell)
    final actualNodeSize = size * 0.6;
    
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: actualNodeSize,
          height: actualNodeSize,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: node.isConnected 
                  ? node.color 
                  : node.color.withOpacity(0.6),
              width: node.isConnected ? 3.0 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: node.isConnected 
                    ? node.color.withOpacity(0.7) 
                    : node.color.withOpacity(0.3),
                blurRadius: node.isConnected ? 12.0 : 8.0,
                spreadRadius: node.isConnected ? 2.0 : 0.0,
              ),
            ],
          ),
          child: Center(
            child: _buildNodeContent(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNodeContent() {
    switch (node.type) {
      case NodeType.start:
        return Icon(
          Icons.power_settings_new,
          size: size * 0.25,
          color: node.color,
        );
        
      case NodeType.end:
        return Icon(
          Icons.electrical_services,
          size: size * 0.25,
          color: node.color,
        );
        
      case NodeType.junction:
        return Icon(
          Icons.add,
          size: size * 0.25,
          color: node.color,
        );
        
      case NodeType.regular:
        return Container(
          width: size * 0.2,
          height: size * 0.2,
          decoration: BoxDecoration(
            color: node.isConnected 
                ? node.color.withOpacity(0.7) 
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
