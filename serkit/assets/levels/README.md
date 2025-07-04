# SerKit Level Files

This directory contains level data for the SerKit game. In a production environment, levels would be stored as JSON files that define the board layout, node positions, and connection rules.

For the current prototype, levels are generated programmatically in the `LevelLoader` class, but this directory structure is set up for future expansion.

## Level File Structure

Each level file would follow this structure:
```json
{
  "level": 1,
  "name": "Tutorial 1",
  "category": "Tutorial",
  "rows": 4,
  "cols": 4,
  "nodes": [
    {
      "row": 0,
      "col": 0,
      "type": "start",
      "isRequired": true
    },
    {
      "row": 3,
      "col": 3,
      "type": "end",
      "isRequired": true
    },
    {
      "row": 1,
      "col": 1,
      "type": "junction",
      "isRequired": true
    }
  ],
  "maxMoves": 5
}
```

## Categories
- tutorial: Beginning levels that teach game mechanics
- classic: Standard difficulty progression
- challenge: More complex puzzles with branching paths
- master: Expert level puzzles requiring optimal solutions
