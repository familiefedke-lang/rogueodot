## InventoryComponent.gd – minimal inventory: list of item keys.
##
## Mirrors src/ecs/components/inventory.py InventoryComponent.

class_name InventoryComponent
extends RefCounted

## Ordered list of held item keys (strings).
var items: Array = []


func _init() -> void:
	items = []


func add(item_key: String) -> void:
	items.append(item_key)
