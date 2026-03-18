## Game.gd – main scene script; owns the Godot game loop.
##
## Mirrors the combination of src/main.py (bootstrap) and src/game.py (loop).
##
## Responsibilities:
##   - _ready():          load assets, create GameEngine, start new game.
##   - _process(delta):  call engine.update(dt) + renderer.render(engine).
##   - _unhandled_input: convert InputEvent → Command → engine.try_player_command().

extends Node2D

var game_engine: GameEngine
var input_handler: InputHandler

## Renderer child node (set in _ready via $Renderer).
@onready var renderer: Renderer = $Renderer


func _ready() -> void:
	# ── Load animation / atlas data ──────────────────────────────────────────
	var animation_db := AnimationDB.new("res://assets/sprites/atlas.json")
	var items_atlas := ItemsAtlas.new("res://assets/sprites/items.atlas.json")

	# ── Load textures ─────────────────────────────────────────────────────────
	var atlas_tex: Texture2D = load("res://assets/sprites/atlas.png")
	var items_tex: Texture2D = load("res://assets/sprites/items.png")
	var icons_tex: Texture2D = load("res://assets/sprites/icons.png")

	# ── Load data DBs ─────────────────────────────────────────────────────────
	var items_db := ItemsDB.new("res://assets/data/items.json")
	var enemies_db := EnemiesDB.new("res://assets/data/enemies.json")

	# ── Wire up renderer ─────────────────────────────────────────────────────
	renderer.setup(atlas_tex, items_tex, icons_tex, animation_db, items_atlas)

	# ── Create engine and start game ─────────────────────────────────────────
	game_engine = GameEngine.new(animation_db, items_db, enemies_db)
	game_engine.set_renderer(renderer)  # Enable visual feedback
	game_engine.new_game()
	game_engine = GameEngine.new(animation_db, items_db, enemies_db)
	game_engine.new_game()

	# ── Input handler ─────────────────────────────────────────────────────────
	input_handler = InputHandler.new()

	# Apply FPS cap
	Engine.max_fps = Constants.FPS

	# Window title
	DisplayServer.window_set_title(Constants.TITLE)


## ── Per-frame update ─────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not game_engine.running:
		return

	# Advance animation state for all sprites
	game_engine.update(delta)

	# Draw everything via Renderer._draw()
	renderer.render(game_engine)


## ── Input handling ───────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not game_engine.running:
		return

	var cmd = input_handler.handle_event(event)
	if cmd != null:
		var turn_taken: bool = game_engine.try_player_command(cmd)
		if turn_taken:
			game_engine.enemy_turns()
