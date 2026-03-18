## Procgen.gd – procedural dungeon generator.
##
## Mirrors src/world/procgen.py generate_floor + Room.
##
## Algorithm (room-and-corridor):
##   1. Start with all WALL.
##   2. Attempt to place random rectangular rooms; reject overlapping ones.
##   3. Carve each room to FLOOR, connect to previous room via L-shaped tunnel.
##   4. Place stairs in the last room.
##   5. Spawn enemies (0-2) in rooms other than the start room.
##   6. Spawn test items (helmet + body armour) every floor.
##
## generate_floor() returns an Array: [game_map, start_x, start_y].

class_name Procgen
extends RefCounted


## ── Room helper ─────────────────────────────────────────────────────────────

class Room extends RefCounted:
	var x: int
	var y: int
	var w: int
	var h: int

	func _init(x_: int, y_: int, w_: int, h_: int) -> void:
		x = x_
		y = y_
		w = w_
		h = h_

	func get_cx() -> int:
		return x + int(w / 2)

	func get_cy() -> int:
		return y + int(h / 2)

	func intersects(other: Room, padding: int = 1) -> bool:
		return (
			x - padding < other.x + other.w
			and x + w + padding > other.x
			and y - padding < other.y + other.h
			and y + h + padding > other.y
		)

	func floor_tiles() -> Array:
		var result: Array = []
		for dx: int in range(w):
			for dy: int in range(h):
				result.append(Vector2i(x + dx, y + dy))
		return result


## ── Tunnel carving ───────────────────────────────────────────────────────────

static func _carve_h_tunnel(game_map: GameMap, x1: int, x2: int, y: int) -> void:
	for x: int in range(min(x1, x2), max(x1, x2) + 1):
		game_map.set_tile(x, y, GameMap.TileType.FLOOR)


static func _carve_v_tunnel(game_map: GameMap, y1: int, y2: int, x: int) -> void:
	for y: int in range(min(y1, y2), max(y1, y2) + 1):
		game_map.set_tile(x, y, GameMap.TileType.FLOOR)


## ── Fisher-Yates shuffle with explicit RNG (for determinism) ────────────────

static func _shuffle_with_rng(arr: Array, rng: RandomNumberGenerator) -> void:
	for i: int in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


## ── Main generator ───────────────────────────────────────────────────────────

## Generate a new dungeon floor.
## *enemies_db* – an EnemiesDB instance used to spawn enemies.
## *rng*        – optional seeded RandomNumberGenerator for determinism.
## Returns [game_map, start_x, start_y].
static func generate_floor(
	floor_num: int,
	enemies_db: EnemiesDB,
	rng: RandomNumberGenerator = null
) -> Array:
	if rng == null:
		rng = RandomNumberGenerator.new()

	var GRID_W: int = Constants.GRID_W
	var GRID_H: int = Constants.GRID_H

	var game_map := GameMap.new()

	var max_rooms: int = 12
	var min_room_size: int = 4
	var max_room_size: int = 10

	var rooms: Array = []

	for _i: int in range(max_rooms):
		var rw: int = rng.randi_range(min_room_size, max_room_size)
		var rh: int = rng.randi_range(min_room_size, max_room_size)
		var rx: int = rng.randi_range(1, GRID_W - rw - 2)
		var ry: int = rng.randi_range(1, GRID_H - rh - 2)
		var new_room := Room.new(rx, ry, rw, rh)

		var overlaps: bool = false
		for existing_room: Room in rooms:
			if new_room.intersects(existing_room):
				overlaps = true
				break
		if overlaps:
			continue

		# Carve room
		for tile_pos: Vector2i in new_room.floor_tiles():
			game_map.set_tile(tile_pos.x, tile_pos.y, GameMap.TileType.FLOOR)

		# Connect to previous room via L-shaped tunnel
		if rooms.size() > 0:
			var prev: Room = rooms[-1]
			if rng.randf() < 0.5:
				_carve_h_tunnel(game_map, prev.get_cx(), new_room.get_cx(), prev.get_cy())
				_carve_v_tunnel(game_map, prev.get_cy(), new_room.get_cy(), new_room.get_cx())
			else:
				_carve_v_tunnel(game_map, prev.get_cy(), new_room.get_cy(), prev.get_cx())
				_carve_h_tunnel(game_map, prev.get_cx(), new_room.get_cx(), new_room.get_cy())

		rooms.append(new_room)

	# Fallback: single central room if no rooms placed
	if rooms.is_empty():
		var fw: int = 10
		var fh: int = 8
		var fx: int = GRID_W / 2 - fw / 2
		var fy: int = GRID_H / 2 - fh / 2
		var fallback := Room.new(fx, fy, fw, fh)
		for tile_pos: Vector2i in fallback.floor_tiles():
			game_map.set_tile(tile_pos.x, tile_pos.y, GameMap.TileType.FLOOR)
		rooms.append(fallback)

	# Player starts in centre of first room
	var start_x: int = rooms[0].get_cx()
	var start_y: int = rooms[0].get_cy()

	# Stairs in last room (or a random non-first room when ≥ 2 rooms)
	var stair_room: Room = rooms[-1] if rooms.size() < 2 else rooms[rng.randi_range(1, rooms.size() - 1)]
	var stair_tiles: Array = []
	for tile_pos: Vector2i in stair_room.floor_tiles():
		if tile_pos != Vector2i(start_x, start_y):
			stair_tiles.append(tile_pos)
	if not stair_tiles.is_empty():
		var stair_pos: Vector2i = stair_tiles[rng.randi_range(0, stair_tiles.size() - 1)]
		game_map.set_tile(stair_pos.x, stair_pos.y, GameMap.TileType.STAIRS)

	# ── Spawn test items: helmet + body armour (always) ──────────────────────
	var item_rooms: Array = rooms.slice(1) if rooms.size() > 1 else rooms.duplicate()
	var item_candidates: Array = []
	for room: Room in item_rooms:
		for tile_pos: Vector2i in room.floor_tiles():
			if tile_pos == Vector2i(start_x, start_y):
				continue
			if game_map.get_tile(tile_pos.x, tile_pos.y) != GameMap.TileType.FLOOR:
				continue
			item_candidates.append(tile_pos)

	if item_candidates.is_empty():
		for cy: int in range(GRID_H):
			for cx: int in range(GRID_W):
				if game_map.get_tile(cx, cy) == GameMap.TileType.FLOOR and Vector2i(cx, cy) != Vector2i(start_x, start_y):
					item_candidates.append(Vector2i(cx, cy))

	_shuffle_with_rng(item_candidates, rng)

	if not item_candidates.is_empty():
		var hpos: Vector2i = item_candidates.pop_back()
		game_map.entities.append(Item.new(hpos.x, hpos.y, "helmet", "helmet"))
	if not item_candidates.is_empty():
		var apos: Vector2i = item_candidates.pop_back()
		game_map.entities.append(Item.new(apos.x, apos.y, "body_armour", "body armour"))

	# ── Spawn enemies in rooms other than start (data-driven) ────────────────
	var enemy_rooms: Array = rooms.slice(1) if rooms.size() > 1 else []
	for room: Room in enemy_rooms:
		var count: int = rng.randi_range(0, 2)
		var occupied: Array = []
		for _j: int in range(count):
			var candidates: Array = []
			for tile_pos: Vector2i in room.floor_tiles():
				if game_map.get_tile(tile_pos.x, tile_pos.y) == GameMap.TileType.FLOOR:
					if not (tile_pos in occupied):
						candidates.append(tile_pos)
			if candidates.is_empty():
				break
			var epos: Vector2i = candidates[rng.randi_range(0, candidates.size() - 1)]
			occupied.append(epos)
			# 50/50 chance between goblin and flower
			var enemy_key: String = "goblin" if rng.randf() < 0.5 else "flower"
			var enemy: Actor = enemies_db.create_actor(enemy_key, epos.x, epos.y, floor_num)
			if enemy != null:
				game_map.entities.append(enemy)

	return [game_map, start_x, start_y]
