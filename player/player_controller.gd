extends Creature

@onready var ROOT_NODE := get_tree().root.get_child(0)

@export var mouse_sensitivity: float = 0.3
@export var interact_range: float = 2.5

@export_category("Movement")
@export var _drag: float = 8
@export var _accel: float = 50

var camera_pitch := 0.0

var look_item: Item = null

var equip_animation_fac := 0.0 # item raising to position, also prevents processing right away
var hp_animation_fac := 0.0    # cool fade + shake effect
var hp_animation_is_heal := true

func get_camera() -> Camera3D:
	return $Camera

func get_backpack() -> Node3D:
	return $Camera/Backpack

func set_item_label(text: String):
	$ItemLabel.text = text

func change_health(amt: int) -> int:
	
	amt = super.change_health(amt)
	
	if amt != 0:
		$Health/Label.text = " " + str(_health)
		$Health/Bar.value = _health
		hp_animation_fac = 1.0
		hp_animation_is_heal = amt > 0
	
	return amt

func _ready() -> void:
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_backpack().visible = false
	$Health/Label.text = " " + str(_health)

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
	
	# equipped item
	if $Camera/HoldAnchor.get_child_count() == 1:
		
		# move bob animation
		$Camera/HoldAnchor.get_child(0).position.y = sin(Time.get_ticks_msec() * 0.02) * velocity.length() * 0.002
		
		# equip animation
		$Camera/HoldAnchor.get_child(0).position.y += -equip_animation_fac * equip_animation_fac * 0.5
		
		# equip timer
		if equip_animation_fac - delta * 4.0 > 0.0:
			equip_animation_fac -= delta * 4.0 # decrease at 240 bpm
		else:
			equip_animation_fac = 0.0
			
			# process equipped item
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				$Camera/HoldAnchor.get_child(0).process_when_equipped(delta, self)
	
	# hp heal/hurt animation
	if hp_animation_is_heal:
		$Health.modulate = Color(1.0 - hp_animation_fac, 1.0, 1.0 - hp_animation_fac * hp_animation_fac, 1.0)
	else:
		$Health.modulate = Color(1.0, 1.0 - hp_animation_fac * hp_animation_fac, 1.0 - hp_animation_fac, 1.0)
	$Health/Label.position.x = sin(hp_animation_fac) * hp_animation_fac * 10.0
	
	if hp_animation_fac - delta * 2.666 > 0.0:
		hp_animation_fac -= delta * 2.666 # decrease at 160 bpm
	else:
		hp_animation_fac = 0.0
	
	# assign look_item (in world or in inventory)
	var new_look_item: Item
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	
		var query = PhysicsRayQueryParameters3D.create(get_camera().global_position, get_camera().global_position - interact_range * get_camera().global_transform.basis.z)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		new_look_item = result.collider if result and result.collider is Item else null;
	
	else:
		
		new_look_item = get_backpack().get_selected_item()
	
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
		
		var rect: Rect2 = get_camera().get_item_ssbb(look_item)
		
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
			get_backpack().visible = true
			$Crosshair.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_backpack().visible = false
			$Crosshair.visible = true
		
		if look_item != null:
			look_item.set_highlight(false)
			look_item = null
	
	elif event.is_action_pressed("interact"): # pick up
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and look_item:
			get_backpack().attempt_store_item(look_item)
		
	elif event.is_action_pressed("fire"): # use/equip
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			
			if look_item:
				
				if look_item is AmmoItem and $Camera/HoldAnchor.get_child_count() == 1 and $Camera/HoldAnchor.get_child(0) is GunItem:
					
					# if you click on an ammo_item in the backpack
					# and you're holding a weapon, if it accepts the
					# corresponding ammo type, it reloads it
					var gun: GunItem = $Camera/HoldAnchor.get_child(0)
					
					if gun.accepted_ammo_type == look_item.ammo_type:
						gun.ammo = look_item.ammo_amount
						look_item.queue_free()
						gun.on_equipped(self) # trigger gun reequip (updates ammo display and plays sound)
					
				else:
				
					# empty the slot
					look_item.reparent(ROOT_NODE)
					
					# can't equip something without first handling what's already equipped
					if $Camera/HoldAnchor.get_child_count() == 1:
						
						var item: Item = $Camera/HoldAnchor.get_child(0)
						
						# if we can't store what's currently equipped, drop it
						if not get_backpack().attempt_store_item(item):
							item.set_rigidbody(true)
							item.reparent(ROOT_NODE)
							item.on_deequipped(self)
						
						# clear item label, as the previously equipped item my have set it
						set_item_label("")
					
					# move the item to the HoldAnchor
					look_item.reparent($Camera/HoldAnchor)
					look_item.position = Vector3.ZERO
					look_item.rotation = Vector3(0, 0, 0)
					
					# start equip animation
					equip_animation_fac = 1.0
					
					# trigger item equip
					look_item.on_equipped(self)
	
	elif event.is_action_pressed("alt_fire"): # drop from inventory
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			
			if look_item:
				look_item.set_rigidbody(true)
				look_item.reparent(ROOT_NODE)
				look_item.on_deequipped(self)
	
	elif event.is_action_pressed("drop"): # drop from hand or inventory
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			
			var item: Item = $Camera/HoldAnchor.get_child(0)
			
			if item:
				item.set_rigidbody(true)
				item.reparent(ROOT_NODE)
				item.on_deequipped(self)
				set_item_label("")
		
		else:
			
			if look_item:
				look_item.set_rigidbody(true)
				look_item.reparent(ROOT_NODE)
				look_item.on_deequipped(self)
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		get_camera().rotation.x = deg_to_rad(camera_pitch)
