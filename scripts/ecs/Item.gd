## Item.gd – a ground item entity.
##
## Mirrors the Item class in src/ecs/item.py.
## blocks = false so actors can stand on it.
## render_layer = 1 so it draws underneath actors.

class_name Item
extends Entity

var item_key: String


func _init(x_: int, y_: int, item_key_: String, name_: String = "") -> void:
	var display_name := name_ if name_ != "" else item_key_
	super._init(x_, y_, false, 1, display_name)
	item_key = item_key_
