## Actor.gd – an entity that can fight, animate, and (optionally) think.
##
## Mirrors the Actor class in src/ecs/entity.py.
## Composes Fighter + SpriteComponent + optional BasicAI
## + InventoryComponent + EquipmentComponent.

class_name Actor
extends Entity


var fighter: Fighter
var sprite: SpriteComponent
## Optional AI component (BasicAI or null).
var ai = null
var inventory: InventoryComponent
var equipment: EquipmentComponent
## Optional ranged attack component (RangedAttackComponent or null).
var ranged_attack = null


func _init(
	x_: int,
	y_: int,
	fighter_: Fighter,
	sprite_: SpriteComponent,
	ai_ = null,
	name_: String = "actor",
	render_layer_: int = 2
) -> void:
	super._init(x_, y_, true, render_layer_, name_)
	fighter = fighter_
	fighter.owner = self
	sprite = sprite_
	ai = ai_
	if ai != null:
		ai.owner = self
	inventory = InventoryComponent.new()
	equipment = EquipmentComponent.new()


func is_alive() -> bool:
	return not fighter.is_dead()
