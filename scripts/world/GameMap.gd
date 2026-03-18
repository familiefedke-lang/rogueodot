## GameMap.gd – owns the 50×30 tile grid and entity list for a single floor.
##
## Mirrors src/world/game_map.py GameMap.

class_name GameMap
extends RefCounted

## Tile type constants – mirrors TileType enum in src/world/tiles.py.
enum TileType { WALL = 0, FLOOR = 1, STAIRS = 2 }

## Tile types that can be walked on – mirrors WALKABLE in src/world/tiles.py.
const WALKABLE: Array = [TileType.FLOOR, TileType.STAIRS]

## 2-D tile array: tiles[y][x] = TileType value.
var tiles: Array = []

## All entities currently on this floor (excludes the player,
## which is tracked separately in GameEngine).
var entities: Array = []


func _init() -> void:
	var grid_w: int = Constants.GRID_W
	var grid_h: int = Constants.GRID_H
	tiles = []
	for _y: int in range(grid_h):
		var row: Array = []
		row.resize(grid_w)
		row.fill(TileType.WALL)
		tiles.append(row)
	entities = []


## ── Bounds helpers ──────────────────────────────────────────────────────────

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < Constants.GRID_W and y >= 0 and y < Constants.GRID_H and y < tiles.size() and x < tiles[y].size()


func get_tile(x: int, y: int) -> int:
	return tiles[y][x]


func set_tile(x: int, y: int, tile: int) -> void:
	tiles[y][x] = tile


## ── Walkability ─────────────────────────────────────────────────────────────

## True if (x, y) is in bounds, tile is walkable, and no blocking entity occupies it.
func is_walkable(x: int, y: int) -> bool:
	if not in_bounds(x, y):
		return false
	if not (tiles[y][x] in WALKABLE):
		return false
	return blocking_entity_at(x, y) == null


## ── Entity lookups ──────────────────────────────────────────────────────────

## Return the first blocking entity at (x, y), or null.
func blocking_entity_at(x: int, y: int):
	for e: Entity in entities:
		if e.blocks and e.x == x and e.y == y:
			return e
	return null


## Return the Actor at (x, y), or null.
func actor_at(x: int, y: int):
	for e: Entity in entities:
		if e is Actor and e.x == x and e.y == y:
			return e
	return null
