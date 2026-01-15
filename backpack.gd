extends Node3D

@export var item_slots: Array[Node3D]
#@export var weapon_slots: Array[Node3D]

func attempt_store_item(item: Item):
	
	for item_slot in item_slots:
		
		if item_slot.get_child_count() == 0:
			item.freeze = true
			item.get_child(0).disabled = true
			item.reparent(item_slot)
			item.position = Vector3.ZERO
			item.rotation = Vector3(0, -PI / 2, 0)
			break
