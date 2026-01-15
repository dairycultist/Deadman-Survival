extends Node3D

@export var item_slots: Array[Node3D]
@export var weapon_slots: Array[Node3D]

# returns true iff item was stored successfully
func attempt_store_item(item: Item) -> bool:
	
	if item.is_weapon:
		
		for slot in weapon_slots:
			
			if slot.get_child_count() == 0:
				
				item.set_highlight(false)
				item.freeze = true
				item.get_child(0).disabled = true
				item.reparent(slot)
				item.position = Vector3.ZERO
				item.rotation = Vector3(0, -PI / 2, 0)
				
				return true
		
	else:
	
		for slot in item_slots:
			
			if slot.get_child_count() == 0:
				
				item.set_highlight(false)
				item.freeze = true
				item.get_child(0).disabled = true
				item.reparent(slot)
				item.position = Vector3.ZERO
				item.rotation = Vector3(0, -PI / 2, 0)
				
				return true
	
	return false

func get_selected_item() -> Item:
	return null
