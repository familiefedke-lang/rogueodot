## EquipmentComponent.gd – holds equipped item keys per slot.
##
## Mirrors src/ecs/components/equipment.py EquipmentComponent.
## Slots are free-form strings ("head", "body", "weapon", …).

class_name EquipmentComponent
extends RefCounted

## Map of slot name → item key.
var slots: Dictionary = {}


func _init() -> void:
	slots = {}


## Return the item key in *slot*, or null if empty.
func equipped_item(slot: String):
	return slots.get(slot, null)


func can_equip(slot: String) -> bool:
	return not slots.has(slot)


## Equip *item_key* into *slot* if empty. Returns true if equipped.
func equip(slot: String, item_key: String) -> bool:
	if slots.has(slot):
		return false
	slots[slot] = item_key
	return true
