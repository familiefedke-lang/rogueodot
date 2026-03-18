## BasicAI.gd – minimal hostile AI component.
##
## Mirrors src/ecs/components/ai.py BasicAI.
## Each turn either:
##   - attacks the player if adjacent (Chebyshev distance ≤ 1), or
##   - moves one step closer (greedy, Manhattan distance).

class_name BasicAI
extends RefCounted

## Back-reference to the owning Actor (untyped to avoid circular dependency).
var owner = null


func _init() -> void:
	owner = null


func take_turn(player: Actor, game_map: GameMap) -> void:
	if owner == null or player == null or game_map == null:
		return
	var enemy: Actor = owner

	var dx: int = player.x - enemy.x
	var dy: int = player.y - enemy.y

	# Adjacent: Chebyshev distance == 1 (diagonals count)
	if max(abs(dx), abs(dy)) <= 1:
		var damage: int = enemy.fighter.base_power
		enemy.fighter.attack(player, damage)
		return

	# Greedy step toward player
	var step_x: int = sign(dx) if dx != 0 else 0
	var step_y: int = sign(dy) if dy != 0 else 0

	var candidates: Array = [
		Vector2i(step_x, step_y),
		Vector2i(step_x, 0),
		Vector2i(0, step_y),
	]

	for candidate: Vector2i in candidates:
		var nx: int = enemy.x + candidate.x
		var ny: int = enemy.y + candidate.y
		if game_map.is_walkable(nx, ny):
			enemy.x = nx
			enemy.y = ny
			if enemy.sprite != null:
				enemy.sprite.set_facing_from_delta(candidate.x, candidate.y)
				enemy.sprite.play("walk", 0.12)
			return
