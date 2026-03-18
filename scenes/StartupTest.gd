## StartupTest.gd – simple test script to verify project setup
##
## This script tests if all resources load correctly and prints
## diagnostic information to help identify configuration issues.

extends Node

func _ready() -> void:
	print("=== Project Startup Test ===")

	# Test Constants autoload
	if Constants == null:
		printerr("ERROR: Constants autoload not loaded!")
	else:
		print("✓ Constants autoload loaded")
		print("  - GRID_W: ", Constants.GRID_W)
		print("  - GRID_H: ", Constants.GRID_H)
		print("  - TILE: ", Constants.TILE)
		print("  - WINDOW_W: ", Constants.WINDOW_W)
		print("  - WINDOW_H: ", Constants.WINDOW_H)

	# Test asset loading
	print("\n=== Testing Asset Loading ===")

	# Test atlas.json
	var animation_db = AnimationDB.new("res://assets/sprites/atlas.json")
	if animation_db == null:
		printerr("ERROR: Failed to load AnimationDB")
	else:
		print("✓ AnimationDB loaded")
		print("  - Tile size: ", animation_db.tile_size)
		print("  - Tiles per row: ", animation_db.tiles_per_row)
		print("  - Default FPS: ", animation_db.default_fps)

	# Test items.atlas.json
	var items_atlas = ItemsAtlas.new("res://assets/sprites/items.atlas.json")
	if items_atlas == null:
		printerr("ERROR: Failed to load ItemsAtlas")
	else:
		print("✓ ItemsAtlas loaded")
		print("  - Tile size: ", items_atlas.tile_size)
		print("  - Tiles per row: ", items_atlas.tiles_per_row)

	# Test items.json
	var items_db = ItemsDB.new("res://assets/data/items.json")
	if items_db == null:
		printerr("ERROR: Failed to load ItemsDB")
	else:
		print("✓ ItemsDB loaded")
		var helmet = items_db.find("helmet")
		if helmet != null:
			print("  - Found helmet: ", helmet.name)
		else:
			printerr("ERROR: Failed to find helmet item")

	# Test enemies.json
	var enemies_db = EnemiesDB.new("res://assets/data/enemies.json")
	if enemies_db == null:
		printerr("ERROR: Failed to load EnemiesDB")
	else:
		print("✓ EnemiesDB loaded")
		var goblin = enemies_db.find("goblin")
		if goblin != null:
			print("  - Found goblin: ", goblin.name, " HP:", goblin.base_hp, " Power:", goblin.base_power)
		else:
			printerr("ERROR: Failed to find goblin enemy")

	# Test texture loading
	print("\n=== Testing Texture Loading ===")
	var atlas_tex: Texture2D = load("res://assets/sprites/atlas.png")
	if atlas_tex == null:
		printerr("ERROR: Failed to load atlas.png")
	else:
		print("✓ atlas.png loaded: ", atlas_tex.get_size())

	var items_tex: Texture2D = load("res://assets/sprites/items.png")
	if items_tex == null:
		printerr("ERROR: Failed to load items.png")
	else:
		print("✓ items.png loaded: ", items_tex.get_size())

	# Test animation database queries
	print("\n=== Testing Animation Database ===")
	if animation_db != null:
		var player_idle_s = animation_db.get_frames("player", "idle", "S")
		print("✓ Player idle S frames: ", player_idle_s)

		var goblin_idle_s = animation_db.get_frames("goblin", "idle", "S")
		print("✓ Goblin idle S frames: ", goblin_idle_s)

	# Test procedural generation
	print("\n=== Testing Procedural Generation ===")
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var gen_result = Procgen.generate_floor(1, enemies_db, rng)
	if gen_result.size() >= 3:
		var test_map = gen_result[0]
		var start_x = gen_result[1]
		var start_y = gen_result[2]
		print("✓ Generated test floor")
		print("  - Player start: ", start_x, ", ", start_y)
		print("  - Entities: ", test_map.entities.size())
		print("  - Walkable tiles: ", test_map.tiles.size())
	else:
		printerr("ERROR: Failed to generate floor")

	print("\n=== Startup Test Complete ===")
	print("If you see any errors above, please fix them before running the main game.")

	# Get tree to quit after test
	await get_tree().process_frame
	get_tree().quit()
