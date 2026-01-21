extends Item

@export var gunshot_sound: AudioStream
@export var dryfire_sound: AudioStream

@export var shots_per_second: float = 3
@export var max_ammo: int = 10

var ammo: int
var base_item_name: String
var shot_cooldown: float

func _ready() -> void:
	super._ready()
	ammo = max_ammo
	base_item_name = item_name
	item_name = base_item_name + " (" + str(ammo) + "/" + str(max_ammo) + ")"

func _process(delta: float) -> void:
	
	$Mesh.rotation.x = lerp($Mesh.rotation.x, 0.0, 10.0 * delta)
	$Mesh.position.z = lerp($Mesh.position.z, 0.0, 10.0 * delta)

func process_when_held(delta: float, player: Creature):
	
	player.set_item_label(str(ammo) + "/" + str(max_ammo))
	
	# use player.get_backpack().get_all_items() for finding ammo during reload
	
	if shot_cooldown > 0.0:
		
		shot_cooldown -= delta * shots_per_second
	
	elif Input.is_action_pressed("fire"):
		
		shot_cooldown = 1.0
		
		if ammo > 0:
			
			$Mesh.rotation.x = 0.3
			$Mesh.position.z = 0.2
			
			ammo -= 1
			item_name = base_item_name + " (" + str(ammo) + "/" + str(max_ammo) + ")"
		
			GlobalAudio.play(gunshot_sound, 1.0, randf_range(0.95, 1.0))
		
			var camera: Camera3D = player.get_camera()
			
			var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - 100.0 * camera.global_transform.basis.z)
			var result = get_world_3d().direct_space_state.intersect_ray(query)
			
			if result and result.collider is Creature:
				result.collider.change_health(-randi_range(8, 14))
		
		else:
			GlobalAudio.play(dryfire_sound, 1.0, randf_range(0.95, 1.0))
