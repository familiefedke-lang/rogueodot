## SpriteComponent.gd – animation state machine for an Actor.
##
## Mirrors src/ecs/components/sprite.py SpriteComponent.
## Tracks: current animation name, facing direction, frame index,
## per-frame timer, and an optional lock that forces an animation to
## finish before returning to idle.

class_name SpriteComponent
extends RefCounted

const DEFAULT_FPS: float = 8.0

var sprite_key: String
var anim: String
var facing: String
var _frame_index: int
var _frame_timer: float
var _lock_timer: float


func _init(
	sprite_key_: String,
	anim_: String = "idle",
	facing_: String = "S"
) -> void:
	sprite_key = sprite_key_
	anim = anim_
	facing = facing_
	_frame_index = 0
	_frame_timer = 0.0
	_lock_timer = 0.0


## Switch to *anim_*, optionally locking it for *lock_for* seconds.
func play(anim_: String, lock_for: float = 0.0) -> void:
	# Always restart the animation when play() is called
	anim = anim_
	_frame_index = 0
	_frame_timer = 0.0
	_lock_timer = max(_lock_timer, lock_for)


## Advance frame timer and lock timer by *dt* seconds.
## Pass *animation_db* (AnimationDB) for data-driven fps / frame counts.
func update(dt: float, animation_db = null) -> void:
	if _lock_timer > 0.0:
		_lock_timer -= dt
		if _lock_timer <= 0.0:
			_lock_timer = 0.0
			# Return to idle only if not permanently locked (dead)
			if anim != "dead":
				anim = "idle"
				_frame_index = 0
				_frame_timer = 0.0

	# Advance animation frame
	var fps: float = DEFAULT_FPS
	if animation_db != null:
		fps = animation_db.get_fps(sprite_key, anim)
	var frame_duration: float = 1.0 / fps
	_frame_timer += dt

	var frame_count: int = 1
	if animation_db != null:
		frame_count = animation_db.get_frames(sprite_key, anim, facing).size()

	if frame_count > 0 and _frame_timer >= frame_duration:
		_frame_timer -= frame_duration
		_frame_index = (_frame_index + 1) % frame_count


## Return the current atlas tile index for this actor.
func current_frame_index(animation_db = null) -> int:
	if animation_db != null:
		var frames: Array = animation_db.get_frames(sprite_key, anim, facing)
		if frames.size() > 0:
			return frames[_frame_index % frames.size()]
	return 0


func set_facing_from_delta(dx: int, dy: int) -> void:
	if dx > 0:
		facing = "E"
	elif dx < 0:
		facing = "W"
	elif dy < 0:
		facing = "N"
	elif dy > 0:
		facing = "S"
