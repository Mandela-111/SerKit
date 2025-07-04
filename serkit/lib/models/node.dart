import 'package:flutter/material.dart';

/// Enumeration of different node types in the circuit
enum NodeType {
  start,   // Starting node with power source
  end,     // End node that needs to be powered
  junction, // Junction node that connects multiple paths
  regular  // Regular node along a path
}

/// Node class representing a connection point in the circuit
class Node {
  final int row;
  final int col;
  final NodeType type;
  bool isConnected;
  bool isRequired;
  final Color color;

  Node({
    required this.row,
    required this.col,
    required this.type,
    this.isConnected = false,
    this.isRequired = true,
    Color? color,
  }) : color = color ?? _getDefaultColorForType(type);

  /// Creates a copy of this node with optional new properties
  Node copyWith({
    int? row,
    int? col,
    NodeType? type,
    bool? isConnected,
    bool? isRequired,
    Color? color,
  }) {
    return Node(
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
      isRequired: isRequired ?? this.isRequired,
      color: color ?? this.color,
    );
  }

  /// Returns a default color based on node type
  static Color _getDefaultColorForType(NodeType type) {
    switch (type) {
      case NodeType.start:
        return const Color(0xFF00FFFF); // Cyan
      case NodeType.end:
        return const Color(0xFF9D4EDD); // Purple
      case NodeType.junction:
        return const Color(0xFF4CC9F0); // Electric blue
      case NodeType.regular:
        return Colors.white;
    }
  }
}
