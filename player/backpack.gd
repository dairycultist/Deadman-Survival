extends Node3D

@export var slot_select_radius := 60.0

@export var item_slots: Array[Node3D]
@export var weapon_slots: Array[Node3D]

# returns true iff item was stored successfully
func attempt_store_item(item: Item) -> bool:
	
	if item.is_weapon:
		
		for slot in weapon_slots:
			
			if slot.get_child_count() == 0:
				
				item.set_rigidbody(false)
				item.reparent(slot)
				item.position = Vector3.ZERO
				item.rotation = Vector3(0, -PI / 2, 0)
				
				return true
		
	else:
	
		for slot in item_slots:
			
			if slot.get_child_count() == 0:
				
				item.set_rigidbody(false)
				item.reparent(slot)
				item.position = Vector3.ZERO
				item.rotation = Vector3(0, -PI / 2, 0)
				
				return true
	
	return false

func get_all_items() -> Array[Item]:
	
	var items: Array[Item]
	
	for slot in item_slots:
		if slot.get_child_count() == 1:
			items.append(slot.get_child(0))
			
	for slot in weapon_slots:
		if slot.get_child_count() == 1:
			items.append(slot.get_child(0))
	
	return items

# returns which item is being hovered on based on the mouse position
func get_selected_item() -> Item:
	
	var mouse_pos := get_viewport().get_mouse_position()
	
	for item in get_all_items():
		
		if get_parent().get_item_ssbb(item).has_point(Vector2(mouse_pos.x, mouse_pos.y)):
			return item
	
	return null
