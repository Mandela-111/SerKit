import 'package:flutter/material.dart';
import 'node.dart';

/// Connection class representing an electrical connection between two nodes
class Connection {
  final Node startNode;
  final Node endNode;
  final Color color;
  final double thickness;
  final bool isValid;

  /// Creates a connection between two nodes
  Connection({
    required this.startNode,
    required this.endNode,
    Color? color,
    this.thickness = 3.0,
    this.isValid = true,
  }) : color = color ?? _deriveConnectionColor(startNode, endNode);

  /// Calculate a connection color based on connected nodes
  static Color _deriveConnectionColor(Node start, Node end) {
    // Blend colors of the two nodes
    if (start.type == NodeType.start || end.type == NodeType.start) {
      return const Color(0xFF00FFFF); // Cyan for connections from start
    } else if (start.type == NodeType.end || end.type == NodeType.end) {
      return const Color(0xFF9D4EDD); // Purple for connections to end
    } else {
      return const Color(0xFF4CC9F0); // Default electric blue
    }
  }

  /// Get Offset position for the start node
  Offset getStartOffset(double nodeSize) {
    return Offset(
      (startNode.col * nodeSize) + (nodeSize / 2),
      (startNode.row * nodeSize) + (nodeSize / 2),
    );
  }

  /// Get Offset position for the end node
  Offset getEndOffset(double nodeSize) {
    return Offset(
      (endNode.col * nodeSize) + (nodeSize / 2),
      (endNode.row * nodeSize) + (nodeSize / 2),
    );
  }
}
