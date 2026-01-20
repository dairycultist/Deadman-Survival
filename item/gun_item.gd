extends Item

@export var gunshot_sound: AudioStream
@export var dryfire_sound: AudioStream

@export var max_ammo: int = 10

var ammo: int
var base_item_name: String

func _ready() -> void:
	super._ready()
	ammo = max_ammo
	base_item_name = item_name
	item_name = base_item_name + " (" + str(ammo) + "/" + str(max_ammo) + ")"

func process_when_held(player: Creature):
	
	player.set_item_label(str(ammo) + "/" + str(max_ammo))
	
	# use player.get_backpack().get_all_items() for finding ammo during reload
	
	if Input.is_action_just_pressed("fire"):
		
		if ammo > 0:
			
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
