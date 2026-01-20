extends Item

@export var gunshot_sound: AudioStream

func _ready() -> void:
	super._ready()

func process_when_held(player: Node3D):
	
	# use player.get_backpack().get_all_items() for finding ammo during reload
	
	if Input.is_action_just_pressed("fire"):
		
		GlobalAudio.play(gunshot_sound, 1.0, randf_range(0.95, 1.0))
	
		var camera: Camera3D = player.get_camera()
		
		var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - 100.0 * camera.global_transform.basis.z)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result and result.collider is Creature:
			result.collider.change_health(-randi_range(8, 14))
