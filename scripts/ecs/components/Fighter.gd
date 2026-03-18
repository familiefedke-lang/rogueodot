## Fighter.gd – owns HP and melee stats for an Actor.
##
## Mirrors src/ecs/components/fighter.py Fighter.

class_name Fighter
extends RefCounted

var max_hp: int
var hp: int
var base_power: int
## Back-reference to the owning Actor (untyped to avoid circular dependency).
var owner = null


func _init(hp_: int, power_: int) -> void:
	max_hp = hp_
	hp = hp_
	base_power = power_
	owner = null


func is_dead() -> bool:
	return hp <= 0


## Apply *amount* damage (already reduced by armor).
## Returns true if the actor just died.
func take_damage(amount: int) -> bool:
	hp = max(0, hp - amount)
	if owner != null and owner.sprite != null:
		if is_dead():
			owner.sprite.play("dead", 999.0)
		else:
			owner.sprite.play("hurt", 0.10)
	return is_dead()


## Attack *target* for *damage* (final, post-armor amount).
## Triggers attack animation on self and hurt/dead animation on target.
## Returns damage dealt.
func attack(target, damage: int) -> int:
	if target == null or target.fighter == null:
		return 0
	target.fighter.take_damage(damage)
	if owner != null and owner.sprite != null:
		owner.sprite.play("attack", 0.15)
	return damage
