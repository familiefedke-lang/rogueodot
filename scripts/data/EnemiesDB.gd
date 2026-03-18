## EnemiesDB.gd – loads enemy definitions from assets/data/enemies.json
## and can instantiate Actor objects.
##
## Mirrors src/data/enemies_db.py EnemiesDB + EnemyDef + EnemyScaling.
##
## Expected JSON schema:
##   {
##     "<key>": {
##       "name":   "<string>",
##       "sprite": "<sprite_key>",
##       "ai":     "basic",
##       "fighter": { "hp": <int>, "power": <int> },
##       "scaling": { "hp_per_floor": <int>, "power_per_floor": <int> }
##     }
##   }

class_name EnemiesDB
extends RefCounted


## ── Data classes ─────────────────────────────────────────────────────────────

class EnemyScaling extends RefCounted:
	var hp_per_floor: int = 0
	var power_per_floor: int = 0


class EnemyDef extends RefCounted:
	var key: String
	var name: String
	var sprite: String
	var ai: String
	var base_hp: int
	var base_power: int
	var scaling: EnemyScaling


## ── Storage ──────────────────────────────────────────────────────────────────

## _enemies["key"] = EnemyDef
var _enemies: Dictionary = {}


## ── Constructor ──────────────────────────────────────────────────────────────

func _init(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("EnemiesDB: cannot open %s" % path)
		return
	var json_text: String = file.get_as_text()
	file.close()

	var raw = JSON.parse_string(json_text)
	if not raw is Dictionary:
		push_error("EnemiesDB: invalid JSON in %s" % path)
		return

	for key in raw:
		var key_l: String = str(key).to_lower()
		var data = raw[key]
		if not data is Dictionary:
			continue

		var def := EnemyDef.new()
		def.key = key_l
		def.name = str(data.get("name", key_l))
		def.sprite = str(data.get("sprite", key_l))
		def.ai = str(data.get("ai", "basic")).to_lower()

		var fighter_data = data.get("fighter", {})
		if not fighter_data is Dictionary:
			fighter_data = {}
		def.base_hp = int(fighter_data.get("hp", 1))
		def.base_power = int(fighter_data.get("power", 1))

		var scaling_raw = data.get("scaling", {})
		if not scaling_raw is Dictionary:
			scaling_raw = {}
		var sc := EnemyScaling.new()
		sc.hp_per_floor = int(scaling_raw.get("hp_per_floor", 0))
		sc.power_per_floor = int(scaling_raw.get("power_per_floor", 0))
		def.scaling = sc

		_enemies[key_l] = def


## ── Public API ───────────────────────────────────────────────────────────────

## Return the EnemyDef for *key*, or null if not found.
## Named "find" (not "get") to avoid shadowing Object.get().
func find(key: String):
	return _enemies.get(key.to_lower(), null)


func require(key: String):
	var e = find(key)
	if e == null:
		push_error("EnemiesDB: unknown enemy key '%s'" % key)
	return e


## Instantiate an Actor for enemy_key at (x, y) with floor scaling applied:
##   stat = base + floor_num * per_floor
func create_actor(enemy_key: String, x: int, y: int, floor_num: int) -> Actor:
	var e: EnemyDef = require(enemy_key)
	if e == null:
		return null

	var hp: int = e.base_hp + floor_num * e.scaling.hp_per_floor
	var power: int = e.base_power + floor_num * e.scaling.power_per_floor

	# AI selector (extend later for additional AI types)
	var ai_obj := BasicAI.new()

	return Actor.new(
		x, y,
		Fighter.new(hp, power),
		SpriteComponent.new(e.sprite, "idle", "S"),
		ai_obj,
		e.name
	)
