## ItemsDB.gd – loads item definitions from assets/data/items.json.
##
## Mirrors src/data/items_db.py ItemsDB + ItemDef.
##
## Expected JSON schema:
##   {
##     "<key>": {
##       "name":      "<string>",
##       "sprite":    "<sprite_key>",
##       "stackable": false,
##       "equip": {
##         "slot":    "<slot_name>",
##         "bonuses": { "<stat>": <int>, ... }
##       }
##     }
##   }

class_name ItemsDB
extends RefCounted


## ── Data class ───────────────────────────────────────────────────────────────

class ItemDef extends RefCounted:
	var key: String
	var name: String
	var sprite: String
	var stackable: bool
	## Equip slot name, or null if not equippable.
	var equip_slot = null
	## Stat bonuses when equipped: { "armor": 3, "power": 1, ... }
	var bonuses: Dictionary = {}


## ── Storage ──────────────────────────────────────────────────────────────────

## _items["key"] = ItemDef
var _items: Dictionary = {}


## ── Constructor ──────────────────────────────────────────────────────────────

func _init(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ItemsDB: cannot open %s" % path)
		return
	var json_text: String = file.get_as_text()
	file.close()

	var raw = JSON.parse_string(json_text)
	if not raw is Dictionary:
		push_error("ItemsDB: invalid JSON in %s" % path)
		return

	for key in raw:
		var key_l: String = str(key).to_lower()
		var data = raw[key]
		if not data is Dictionary:
			continue

		var def := ItemDef.new()
		def.key = key_l
		def.name = str(data.get("name", key))
		def.sprite = str(data.get("sprite", key))
		def.stackable = bool(data.get("stackable", false))

		var equip = data.get("equip", null)
		def.equip_slot = null
		def.bonuses = {}
		if equip is Dictionary:
			var slot = equip.get("slot", null)
			def.equip_slot = str(slot) if slot != null else null
			var b = equip.get("bonuses", {})
			if b is Dictionary:
				for bk in b:
					def.bonuses[str(bk)] = int(b[bk])

		_items[key_l] = def


## ── Public API ───────────────────────────────────────────────────────────────

## Return the ItemDef for *key*, or null if not found.
## Named "find" (not "get") to avoid shadowing Object.get().
func find(key: String):
	return _items.get(key.to_lower(), null)


func require(key: String):
	var item = find(key)
	if item == null:
		push_error("ItemsDB: unknown item key '%s'" % key)
	return item
