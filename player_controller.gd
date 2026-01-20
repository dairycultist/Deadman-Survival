extends CharacterBody3D

@onready var ROOT_NODE := get_tree().root.get_child(0)

@export var mouse_sensitivity: float = 0.3
@export var interact_range: float = 2.5

@export_category("Survival")
@export_range(0, 100, 1) var _health: int = 100

@export_category("Movement")
@export var _drag: float = 8
@export var _accel: float = 50

var camera_pitch := 0.0

var look_item: Item = null

func get_camera() -> Camera3D:
	return $Camera

func get_backpack():
	return $Camera/Backpack

func damage(amt: int):
	_health -= amt
	$HealthLabel.text = "[font_size=48]" + str(_health) + "/100 HP[/font_size]"

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera/Backpack.visible = false
	damage(0)

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x += direction.x * _accel * delta
		velocity.z += direction.z * _accel * delta
	
	velocity += get_gravity() * 2.5 * delta
	velocity = lerp(velocity, Vector3.ZERO, delta * _drag)
	
	move_and_slide()
	
	# process equipped item
	if $Camera/HoldAnchor.get_child_count() == 1:
		$Camera/HoldAnchor.get_child(0).process_when_held(self)
	
	# assign look_item (in world or in inventory)
	var new_look_item: Item
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	
		var query = PhysicsRayQueryParameters3D.create($Camera.global_position, $Camera.global_position - interact_range * $Camera.global_transform.basis.z)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		new_look_item = result.collider if result and result.collider is Item else null;
	
	else:
		
		new_look_item = $Camera/Backpack.get_selected_item()
	
	if new_look_item:
			
		if look_item != new_look_item:
			if look_item:
				look_item.set_highlight(false)
			look_item = new_look_item
			look_item.set_highlight(true)
		
	elif look_item:
		
		look_item.set_highlight(false)
		look_item = null
	
	# ItemHover and ItemTooltip display
	if look_item:
		
		var rect: Rect2 = $Camera.get_item_ssbb(look_item)
		
		$ItemHover.position = rect.position
		$ItemHover.size     = rect.size
		$ItemHover.visible  = true
		
		$ItemTooltip/Text.text = "[font_size=28][color=white][b]" + look_item.item_name + "[/b][br][/color][color=gray][i]" + look_item.item_description + "[/i][/color][/font_size]"
		$ItemTooltip.position  = rect.position + Vector2(rect.size.x + $ItemHover.border_width / 2, -$ItemHover.border_width / 2)
		$ItemTooltip.size      = $ItemTooltip/Text.size + Vector2(20.0, 20.0)
		
	else:
		
		$ItemHover.visible     = false
		
		# we don't just make it invisible because for a single frame when
		# un-invisibling it, it would show the text it previously had (bad!)
		$ItemTooltip.size      = Vector2(0.0, 0.0)
		$ItemTooltip/Text.text = ""

func _input(event):
	
	if event.is_action_pressed("inventory"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$Camera/Backpack.visible = true
			$Crosshair.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$Camera/Backpack.visible = false
			$Crosshair.visible = true
		
		if look_item != null:
			look_item.set_highlight(false)
			look_item = null
	
	elif event.is_action_pressed("interact"): # pick up
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and look_item:
			$Camera/Backpack.attempt_store_item(look_item)
		
	elif event.is_action_pressed("fire"): # equip
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			
			if look_item:
				
				# empty the slot
				look_item.reparent(ROOT_NODE)
				
				# can't equip something without first handling what's already equipped
				if $Camera/HoldAnchor.get_child_count() == 1:
					
					var item: Item = $Camera/HoldAnchor.get_child(0)
					
					# if we can't store what's currently equipped, drop it
					if not $Camera/Backpack.attempt_store_item(item):
						item.set_rigidbody(true)
						item.reparent(ROOT_NODE)
				
				# move the item to the HoldAnchor
				look_item.reparent($Camera/HoldAnchor)
				look_item.position = Vector3.ZERO
				look_item.rotation = Vector3(0, 0, 0)
	
	elif event.is_action_pressed("alt_fire"): # drop
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			
			if look_item:
				look_item.set_rigidbody(true)
				look_item.reparent(get_tree().root.get_child(0))
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		$Camera.rotation.x = deg_to_rad(camera_pitch)
