extends CharacterBody3D

@export var mouse_sensitivity := 0.3
@export var interact_range := 10.0

@export_category("Movement")
@export var drag := 8
@export var accel := 50

var camera_pitch := 0.0

var look_item: Item = null
var held_item: Item = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CameraAnchor/Backpack.visible = false

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x += direction.x * accel * delta
		velocity.z += direction.z * accel * delta
	
	velocity += get_gravity() * 2.5 * delta
	velocity = lerp(velocity, Vector3.ZERO, delta * drag)
	
	move_and_slide()
	
	# looking at item (in world or in inventory)
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	
		var query = PhysicsRayQueryParameters3D.create($CameraAnchor.global_position, $CameraAnchor.global_position - interact_range * $CameraAnchor.global_transform.basis.z)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result and result.collider is Item:
			
			if look_item != result.collider:
				if look_item:
					look_item.set_highlight(false)
				look_item = result.collider
				look_item.set_highlight(true)
			
		elif look_item:
			
			look_item.set_highlight(false)
			look_item = null
	
	else:
		
		var new_look_item: Item = $CameraAnchor/Backpack.get_selected_item()
		
		if new_look_item:
			
			if look_item != new_look_item:
				if look_item:
					look_item.set_highlight(false)
				look_item = new_look_item
				look_item.set_highlight(true)
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			
		elif look_item != null:
			
			look_item.set_highlight(false)
			look_item = null
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event):
	
	if event.is_action_pressed("inventory"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$CameraAnchor/Backpack.visible = true
			$Crosshair.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$CameraAnchor/Backpack.visible = false
			$Crosshair.visible = true
		
		if look_item != null:
			look_item.set_highlight(false)
			look_item = null
	
	elif event.is_action_pressed("interact"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			
			if look_item and $CameraAnchor/Backpack.attempt_store_item(look_item):
				look_item = null
		
	elif event.is_action_pressed("fire"): # equip
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			
			if look_item:
				print("Attempting to equip: " + str(look_item))
	
	elif event.is_action_pressed("alt_fire"): # drop
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			
			if look_item:
				
				look_item.set_highlight(false)
				look_item.freeze = false
				look_item.get_child(0).disabled = false
				look_item.reparent(get_tree().root.get_child(0))
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)
