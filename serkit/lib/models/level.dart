
/// Represents a level in the SerKit game
class Level {
  final int id;
  final String name;
  final String difficulty;
  final GridSize gridSize;
  final List<LevelNode> nodes;
  final List<String> hints;
  final List<Connection> targetConnections;
  final ParScore par;
  final int maxConnections;

  Level({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.gridSize,
    required this.nodes,
    required this.hints,
    required this.targetConnections,
    required this.par,
    required this.maxConnections,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      gridSize: GridSize.fromJson(json['gridSize'] as Map<String, dynamic>),
      nodes: (json['nodes'] as List)
          .map((e) => LevelNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List).map((e) => e as String).toList(),
      targetConnections: (json['targetConnections'] as List)
          .map((e) => Connection.fromJson(e as Map<String, dynamic>))
          .toList(),
      par: ParScore.fromJson(json['par'] as Map<String, dynamic>),
      maxConnections: json['maxConnections'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'gridSize': gridSize.toJson(),
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'hints': hints,
      'targetConnections': targetConnections.map((e) => e.toJson()).toList(),
      'par': par.toJson(),
      'maxConnections': maxConnections,
    };
  }
}

/// Represents a node in a level
class LevelNode {
  final int id;
  final String type;
  final Position position;
  final List<int> connectedTo;

  LevelNode({
    required this.id,
    required this.type,
    required this.position,
    required this.connectedTo,
  });

  factory LevelNode.fromJson(Map<String, dynamic> json) {
    return LevelNode(
      id: json['id'] as int,
      type: json['type'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      connectedTo: (json['connectedTo'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': position.toJson(),
      'connectedTo': connectedTo,
    };
  }
}

/// Represents a position on the grid
class Position {
  final int x;
  final int y;

  Position({required this.x, required this.y});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'] as int,
      y: json['y'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

/// Represents the grid size of a level
class GridSize {
  final int width;
  final int height;

  GridSize({required this.width, required this.height});

  factory GridSize.fromJson(Map<String, dynamic> json) {
    return GridSize(
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

/// Represents a connection between nodes
class Connection {
  final int from;
  final int to;

  Connection({required this.from, required this.to});

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      from: json['from'] as int,
      to: json['to'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

/// Represents par score for a level
class ParScore {
  final int moves;
  final int time;

  ParScore({required this.moves, required this.time});

  factory ParScore.fromJson(Map<String, dynamic> json) {
    return ParScore(
      moves: json['moves'] as int,
      time: json['time'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moves': moves,
      'time': time,
    };
  }
}
