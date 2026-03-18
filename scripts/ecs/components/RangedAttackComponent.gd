## RangedAttackComponent.gd – handles ranged attacks for Actors.
##
## Provides ranged attack functionality independent of melee attacks.
## Can be equipped to both player and enemies.

class_name RangedAttackComponent
extends RefCounted

var base_power: int
var range: int
var cooldown: float
var current_cooldown: float = 0.0
var projectile_anim: String  # Animation name for visual feedback
## Back-reference to the owning Actor (untyped to avoid circular dependency).
var owner = null


func _init(power_: int, range_: int = 33, cooldown_: float = 1.0, proj_anim_: String = "projectile") -> void:
	base_power = power_
	range = range_
	cooldown = cooldown_
	projectile_anim = proj_anim_
	owner = null


## Update cooldown timer.
func update(dt: float) -> void:
	if current_cooldown > 0.0:
		current_cooldown -= dt
		if current_cooldown < 0.0:
			current_cooldown = 0.0


## Check if ranged attack is available.
func can_attack() -> bool:
	return current_cooldown <= 0.0


## Perform ranged attack on *target*.
## Returns damage dealt, or 0 if attack not possible.
func attack(target, damage: int = base_power) -> int:
	if not can_attack():
		return 0

	if target == null:
		return 0

	# Trigger attack animation on owner
	if owner != null and owner.sprite != null:
		owner.sprite.play("attack", 0.15)

	# Trigger hurt/dead animation on target
	if target.fighter != null:
		target.fighter.take_damage(damage)

	# Set cooldown
	current_cooldown = cooldown

	return damage


## Calculate actual damage (can be overridden for bonuses/etc).
func get_damage() -> int:
	return base_power


## Check if *target* is within attack range.
func is_in_range(target) -> bool:
	if owner == null or target == null:
		return false

	var dx: int = abs(target.x - owner.x)
	var dy: int = abs(target.y - owner.y)

	# Use Chebyshev distance for diagonal attacks
	return max(dx, dy) <= range


## Get a list of all potential targets in range on *game_map*.
func get_targets_in_range(game_map) -> Array:
	if owner == null or game_map == null:
		return []

	var targets: Array = []

	# Check all entities on the map
	for entity in game_map.entities:
		if entity is Actor and entity != owner and is_in_range(entity):
			targets.append(entity)

	return targets
