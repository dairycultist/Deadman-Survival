extends Node3D

@export var slot_select_radius := 60.0

@export var item_slots: Array[Node3D]
@export var weapon_slots: Array[Node3D]

# screen space bounding box for selection with mouse
func get_item_ssbb(item: Item) -> Rect2:
	
	var aabb: AABB = item.mesh().get_aabb()
	var screen_points := []
	
	for i in range(8):
		screen_points.append(
			get_parent().unproject_position( # project into screenspace
				item.to_global(              # put into global space
					aabb.get_endpoint(i)     # local space AABB corner
				)
			)
		)

	# fnd the bounds of the final screen space bounding box
	var min_x: float =  INF
	var max_x: float = -INF
	var min_y: float =  INF
	var max_y: float = -INF

	for p in screen_points:
		if p.x < min_x:
			min_x = p.x
		elif p.x > max_x:
			max_x = p.x
		if p.y < min_y:
			min_y = p.y
		elif p.y > max_y:
			max_y = p.y

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

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

# returns which item is being hovered on based on the mouse position
func get_selected_item() -> Item:
	
	var mouse_pos := get_viewport().get_mouse_position()
	
	var slots := item_slots.duplicate()
	slots.append_array(weapon_slots)
	
	for slot in slots:
		
		if slot.get_child_count() == 1 and get_item_ssbb(slot.get_child(0)).has_point(Vector2(mouse_pos.x, mouse_pos.y)):
			return slot.get_child(0)
	
	return null
