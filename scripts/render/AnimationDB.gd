## AnimationDB.gd – loads animation frame-list definitions from atlas.json.
##
## Mirrors src/render/animations.py AnimationDB.
##
## Expected atlas.json schema:
##   {
##     "tileSize":    32,
##     "tilesPerRow": <int>,
##     "defaultFps":  8,
##     "tiles": { "wall": 0, "floor": 1, "stairs": 2 },
##     "sprites": {
##       "<sprite_key>": {
##         "<anim_name>": {
##           "<facing>": [<tile_index>, ...],
##           "fps": <optional float>
##         }
##       }
##     }
##   }
##
## Facing keys: "N", "S", "E", "W".
## Fallback chain: requested → "S" → first available → [0].

class_name AnimationDB
extends RefCounted

var tile_size: int
var tiles_per_row: int
var default_fps: float

## tile_sprites["wall"] = 0, ["floor"] = 1, etc.
var _tile_sprites: Dictionary = {}

## _db[sprite_key][anim_name][facing] = Array[int]
var _db: Dictionary = {}

## _fps["sprite_key::anim_name"] = float
var _fps: Dictionary = {}


func _init(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("AnimationDB: cannot open %s" % path)
		return
	var json_text: String = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)
	if not data is Dictionary:
		push_error("AnimationDB: invalid JSON in %s" % path)
		return

	tile_size = int(data.get("tileSize", 32))
	tiles_per_row = int(data.get("tilesPerRow", 8))
	default_fps = float(data.get("defaultFps", 8.0))

	# Tile sprite index map
	var tiles_data = data.get("tiles", {})
	if tiles_data is Dictionary:
		for k: String in tiles_data:
			_tile_sprites[k.to_lower()] = int(tiles_data[k])

	# Sprite animation data
	var sprites_data = data.get("sprites", {})
	if not sprites_data is Dictionary:
		return

	for sprite_key: String in sprites_data:
		_db[sprite_key] = {}
		var anims = sprites_data[sprite_key]
		if not anims is Dictionary:
			continue
		for anim_name: String in anims:
			if anim_name == "fps":
				continue
			_db[sprite_key][anim_name] = {}
			var facing_data = anims[anim_name]
			if not facing_data is Dictionary:
				continue
			var anim_fps: float = float(facing_data.get("fps", default_fps))
			_fps[sprite_key + "::" + anim_name] = anim_fps
			for facing: String in facing_data:
				if facing == "fps":
					continue
				_db[sprite_key][anim_name][facing] = facing_data[facing]


## Return list of atlas tile indices for sprite_key / anim / facing.
## Falls back gracefully: facing → "S" → first facing → [0].
func get_frames(sprite_key: String, anim: String, facing: String = "S") -> Array:
	var sprite_db = _db.get(sprite_key, null)
	if sprite_db == null:
		return [0]
	var anim_db = sprite_db.get(anim, null)
	if anim_db == null:
		anim_db = sprite_db.get("idle", null)
	if anim_db == null or (anim_db is Dictionary and anim_db.is_empty()):
		return [0]
	if anim_db.has(facing):
		return anim_db[facing]
	if anim_db.has("S"):
		return anim_db["S"]
	# Return first available facing
	if anim_db is Dictionary and not anim_db.is_empty():
		var values = anim_db.values()
		if values.size() > 0:
			return values[0]
	return [0]


func get_fps(sprite_key: String, anim: String) -> float:
	return _fps.get(sprite_key + "::" + anim, default_fps)


## Return the atlas tile index for a map tile type name
## ("wall", "floor", "stairs"). Falls back to *default_val*.
func get_tile_sprite(tile_name: String, default_val: int = 0) -> int:
	return _tile_sprites.get(tile_name.to_lower(), default_val)
