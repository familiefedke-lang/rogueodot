## ItemsAtlas.gd – loads items.atlas.json and maps item keys to tile indices.
##
## Mirrors src/render/items_atlas.py ItemsAtlas.
##
## Expected JSON schema:
##   {
##     "tileSize":    32,
##     "tilesPerRow": <int>,
##     "items": { "item_key": <tile_index>, ... }
##   }

class_name ItemsAtlas
extends RefCounted

var tile_size: int
var tiles_per_row: int

## _items["item_key"] = tile_index
var _items: Dictionary = {}


func _init(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ItemsAtlas: cannot open %s" % path)
		return
	var json_text: String = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)
	if not data is Dictionary:
		push_error("ItemsAtlas: invalid JSON in %s" % path)
		return

	tile_size = int(data.get("tileSize", 32))
	tiles_per_row = int(data.get("tilesPerRow", 3))

	var items_data = data.get("items", {})
	if items_data is Dictionary:
		for k: String in items_data:
			_items[k.to_lower()] = int(items_data[k])


## Return the tile index for *item_key*, or *default_val* if not found.
func get_item_index(item_key: String, default_val: int = 0) -> int:
	return _items.get(item_key.to_lower(), default_val)
