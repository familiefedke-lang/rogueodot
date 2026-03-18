## Entity.gd – base game object that occupies a tile position.
##
## Mirrors the Entity class in src/ecs/entity.py.
## Uses RefCounted so instances are automatically freed when unreferenced.

class_name Entity
extends RefCounted

var x: int
var y: int
var blocks: bool
var render_layer: int
var name: String


func _init(
	x_: int,
	y_: int,
	blocks_: bool = false,
	render_layer_: int = 2,
	name_: String = "entity"
) -> void:
	x = x_
	y = y_
	blocks = blocks_
	render_layer = render_layer_
	name = name_
