extends Node3D

@export var slot_select_radius := 60.0

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

# returns which item is being hovered on based on the mouse position
func get_selected_item() -> Item:
	
	var mouse_pos := get_viewport().get_mouse_position()
	
	var slots := item_slots.duplicate()
	slots.append_array(weapon_slots)
	
	for slot in slots:
		
		var item_slot_pos: Vector2 = get_parent().unproject_position(slot.global_position)
		
		# use Chebyshev distance
		if max(abs(mouse_pos.x - item_slot_pos.x), abs(mouse_pos.y - item_slot_pos.y)) < slot_select_radius and slot.get_child_count() == 1:
			return slot.get_child(0)
	
	return null
