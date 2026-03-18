## Renderer.gd – thin drawing layer around Godot's Node2D canvas API.
##
## Mirrors src/render/renderer.py Renderer.
## Attached to a Node2D child of Main; draws via _draw() which is invoked
## automatically by Godot every frame after queue_redraw() is called.
##
## All positional arguments use tile coordinates unless the
## comment says "pixels" (px).

class_name Renderer
extends Node2D

const BG_COLOR := Color(0.039, 0.039, 0.078)
const UI_COLOR := Color(0.0, 0.0, 0.0)  # Black text
const HP_BAR_FG := Color(0.706, 0.118, 0.118)
const HP_BAR_BG := Color(0.235, 0.235, 0.235)
const PANEL_BG := Color(0.0, 0.0, 0.0, 0.667)
const PANEL_BORDER := Color(0.314, 0.314, 0.392)
const MSG_COLOR := Color(0.902, 0.902, 0.820)
const PROJECTILE_COLOR := Color(1.0, 1.0, 0.5)  # Yellow projectiles
const RANGE_INDICATOR_COLOR := Color(1.0, 0.5, 0.5)  # Red for invalid range

## Loaded in setup().
var _atlas_texture: Texture2D = null
var _items_texture: Texture2D = null
var _icons_texture: Texture2D = null
var animation_db: AnimationDB = null
var items_atlas: ItemsAtlas = null

## Ranged attack visual feedback
var _active_projectiles: Array = []  # Array of {"from": Vector2i, "to": Vector2i, "progress": float}

## Reference to the active GameEngine; set by render() before _draw() fires.
var _game_engine = null

## Fallback font (system monospace)
var _font: Font = null
const _font_size: int = 24  # Increased from 14 to 24 for larger text


func _ready() -> void:
	_font = ThemeDB.fallback_font


## Called once by Game._ready() to provide asset references.
func setup(
	atlas_tex: Texture2D,
	items_tex: Texture2D,
	icons_tex: Texture2D,
	anim_db: AnimationDB,
	it_atlas: ItemsAtlas
) -> void:
	_atlas_texture = atlas_tex
	_items_texture = items_tex
	_icons_texture = icons_tex
	animation_db = anim_db
	items_atlas = it_atlas


## Store current engine state and request a redraw.
## Called every frame from Game._process().
func render(game_engine) -> void:
	_game_engine = game_engine
	# Update projectile animations
	_update_projectiles()
	queue_redraw()


## Add a projectile visual effect from (from_x, from_y) to (to_x, to_y).
func add_projectile(from_x: int, from_y: int, to_x: int, to_y: int) -> void:
	var projectile := {
		"from": Vector2i(from_x, from_y),
		"to": Vector2i(to_x, to_y),
		"progress": 0.0
	}
	_active_projectiles.append(projectile)


## Update projectile animations.
func _update_projectiles() -> void:
	var speed: float = 0.15  # Projectile speed (tiles per frame)
	var finished: Array = []

	for i in range(_active_projectiles.size()):
		var proj = _active_projectiles[i]
		proj.progress += speed
		if proj.progress >= 1.0:
			finished.append(i)

	# Remove finished projectiles (in reverse order to avoid index issues)
	for i in range(finished.size() - 1, -1, -1):
		_active_projectiles.remove_at(finished[i])


## Draw a projectile effect.
func _draw_projectiles() -> void:
	var T: int = Constants.TILE

	for proj in _active_projectiles:
		var from: Vector2i = proj.from
		var to: Vector2i = proj.to
		var progress: float = proj.progress

		# Calculate current position
		var current_x: float = from.x + (to.x - from.x) * progress
		var current_y: float = from.y + (to.y - from.y) * progress

		# Draw projectile as a filled circle
		var radius: float = T * 0.25
		draw_circle(Vector2(current_x * T + T / 2, current_y * T + T / 2), radius, PROJECTILE_COLOR)


## ── Canvas draw callback ──────────────────────────────────────────────────────

func _draw() -> void:
	if _game_engine == null:
		return

	var ge = _game_engine

	# Background fill
	draw_rect(Rect2(0.0, 0.0, Constants.WINDOW_W, Constants.WINDOW_H), BG_COLOR)

	# Map tiles
	for ty: int in range(Constants.GRID_H):
		for tx: int in range(Constants.GRID_W):
			_draw_tile(ge.game_map.get_tile(tx, ty), tx, ty)

	# Draw projectiles
	_draw_projectiles()

	# Entities sorted by render_layer
	var drawables: Array = ge.game_map.entities.duplicate()
	drawables.append(ge.player)
	drawables.sort_custom(func(a, b): return a.render_layer < b.render_layer)

	for e in drawables:
		if e is Item:
			_draw_item(e)
		elif e is Actor:
			_draw_actor(e)

	# HUD overlay
	_draw_ui(ge)


## ── Tile / sprite drawing ─────────────────────────────────────────────────────

func _draw_tile(tile_type: int, tx: int, ty: int) -> void:
	var tile_name: String = ""
	match tile_type:
		GameMap.TileType.WALL:   tile_name = "wall"
		GameMap.TileType.FLOOR:  tile_name = "floor"
		GameMap.TileType.STAIRS: tile_name = "stairs"
	var fallback: int = tile_type  # WALL=0, FLOOR=1, STAIRS=2 happen to match defaults
	var tile_index: int = animation_db.get_tile_sprite(tile_name, fallback)
	_blit_from_atlas(_atlas_texture, animation_db.tiles_per_row, tile_index,
		tx * Constants.TILE, ty * Constants.TILE)


func _draw_item(item: Item) -> void:
	var tile_index: int = items_atlas.get_item_index(item.item_key, 0)
	_blit_from_atlas(_items_texture, items_atlas.tiles_per_row, tile_index,
		item.x * Constants.TILE, item.y * Constants.TILE)


func _draw_actor(actor: Actor) -> void:
	if actor.sprite == null:
		return
	var frame_index: int = actor.sprite.current_frame_index(animation_db)
	_blit_from_atlas(_atlas_texture, animation_db.tiles_per_row, frame_index,
		actor.x * Constants.TILE, actor.y * Constants.TILE)


## Blit one tile from *texture* at screen pixel position (screen_x, screen_y).
func _blit_from_atlas(
	texture: Texture2D,
	tiles_per_row: int,
	tile_index: int,
	screen_x: int,
	screen_y: int
) -> void:
	if texture == null:
		return
	var T: int = Constants.TILE
	var col: int = tile_index % tiles_per_row
	var row: int = tile_index / tiles_per_row
	var src_rect := Rect2(col * T, row * T, T, T)
	var dest_rect := Rect2(screen_x, screen_y, T, T)
	draw_texture_rect_region(texture, dest_rect, src_rect)


## Draw an icon from icons texture at screen pixel position (screen_x, screen_y).
## icon_x and icon_y are the tile coordinates in the icons.png file.
## size is the icon size in pixels (default: TILE size).
func _draw_icon(texture: Texture2D, icon_x: int, icon_y: int, screen_x: int, screen_y: int, size: int = Constants.TILE) -> void:
	if texture == null:
		return
	var src_rect := Rect2(icon_x * size, icon_y * size, size, size)
	var dest_rect := Rect2(screen_x, screen_y, size, size)
	draw_texture_rect_region(texture, dest_rect, src_rect)


## ── HUD / UI drawing ─────────────────────────────────────────────────────────

func _draw_ui(ge) -> void:
	if ge.player == null or ge.player.fighter == null:
		return
	var f: Fighter = ge.player.fighter

	var T: int = Constants.TILE
	var spacing: int = _font_size + 8  # Spacing for larger text

	# Health icon and HP value (top-left)
	_draw_icon(_icons_texture, 0, 0, 8, 8, T)
	_draw_text("%d/%d" % [f.hp, f.max_hp], 8 + T + 8, 8 + 24)

	# HP bar below health text
	_draw_hp_bar(8, 8 + T + 8, T + 80, 10, f.hp, f.max_hp)

	# Armor icon and armor value (below health)
	_draw_icon(_icons_texture, 0, 1, 8, 8 + T + spacing, T)
	_draw_text("%d" % ge._armor(ge.player), 8 + T + 8, 8 + T + spacing + 24)

	# Floor number (below armor)
	_draw_text("Floor: %d" % ge.floor_num, 8, 8 + T * 2 + spacing + 16)
	_draw_text("Power: %d" % ge._power(ge.player), 8, 8 + T * 2 + spacing + 32)

	# Bottom-left console panel
	var panel_x: int = 8
	var panel_h: int = 220
	var panel_w: int = 520
	var panel_y: int = Constants.WINDOW_H - panel_h - 8

	_draw_panel(panel_x, panel_y, panel_w, panel_h)

	# Text inside panel
	var padding: int = 8
	var line_h: int = _font_size + 4  # Increased line height for larger font
	var max_lines: int = (panel_h - 2 * padding) / line_h

	var start_idx: int = max(0, ge.messages.size() - max_lines)
	var lines: Array = ge.messages.slice(start_idx)

	var ty: int = panel_y + padding
	for msg: String in lines:
		_draw_text(msg, panel_x + padding, ty, MSG_COLOR)
		ty += line_h


## Draw text at pixel position (px, py).
## Godot's draw_string baseline is at py + ascent, so we offset by font_size.
func _draw_text(
	text: String,
	px: int,
	py: int,
	color: Color = UI_COLOR
) -> void:
	if _font == null:
		return
	draw_string(
		_font,
		Vector2(px, py + _font_size),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		_font_size,
		color
	)


## Draw a filled HP bar at pixel position (px, py).
func _draw_hp_bar(px: int, py: int, width: int, height: int, hp: int, max_hp: int) -> void:
	var ratio: float = float(max(0, hp)) / max_hp if max_hp > 0 else 0.0
	draw_rect(Rect2(px, py, width, height), HP_BAR_BG)
	draw_rect(Rect2(px, py, int(width * ratio), height), HP_BAR_FG)


## Draw a semi-transparent panel at pixel position (px, py).
func _draw_panel(px: int, py: int, width: int, height: int) -> void:
	draw_rect(Rect2(px, py, width, height), PANEL_BG)
	draw_rect(Rect2(px, py, width, height), PANEL_BORDER, false)
