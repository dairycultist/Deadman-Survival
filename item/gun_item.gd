extends Item

@export var gunshot_sound: AudioStream

var audio: AudioStreamPlayer

func _ready() -> void:
	super._ready()
	audio = AudioStreamPlayer.new()
	add_child(audio)

func process_when_held(player: Node3D):
	
	if Input.is_action_just_pressed("fire"):
		
		audio.stream = gunshot_sound
		audio.play()
	
		var camera: Camera3D = player.get_camera()
		
		var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - 100.0 * camera.global_transform.basis.z)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result and result.collider is Creature:
			result.collider.change_health(-randi_range(8, 14))
