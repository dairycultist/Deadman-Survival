extends Item
class_name GunItem

@export var gunshot_sound: AudioStream
@export var dryfire_sound: AudioStream
@export var reload_sound: AudioStream

@export var shots_per_second: float = 3
@export var ammo: int
@export var damage: int = 10

@export var accepted_ammo_type: String = "pistol"

var base_item_name: String
var shot_cooldown: float

func _ready() -> void:
	super._ready()
	base_item_name = item_name
	item_name = base_item_name + " (" + str(ammo) + ")"

func _process(delta: float) -> void:
	
	$Mesh.rotation.x = lerp($Mesh.rotation.x, 0.0, 10.0 * delta)
	$Mesh.position.z = lerp($Mesh.position.z, 0.0, 10.0 * delta)
	$Mesh/MuzzleFlash.scale = lerp($Mesh/MuzzleFlash.scale, Vector3.ZERO, 10.0 * delta)

func attempt_reload(ammo_item: AmmoItem) -> bool:
	
	# if you click on an ammo_item in the backpack and you're holding a gun:
	# - if the gun accepts the corresponding ammo type, and
	# - it has less ammo than what the ammo_item would provide
	# then it reloads it
	if accepted_ammo_type == ammo_item.ammo_type and ammo < ammo_item.ammo_amount:
		ammo = ammo_item.ammo_amount
		return true
	
	return false

func on_equipped(player: Creature):
	player.set_item_label(str(ammo))
	GlobalAudio.play(reload_sound, 1.0, randf_range(0.95, 1.0))

func process_when_equipped(delta: float, player: Creature):
	
	if shot_cooldown > 0.0:
		
		shot_cooldown -= delta * shots_per_second
	
	elif Input.is_action_pressed("fire"):
		
		shot_cooldown = 1.0
		
		if ammo > 0:
			
			$Mesh.rotation.x = 0.1
			$Mesh.position.z = 0.2
			$Mesh/MuzzleFlash.scale = Vector3.ONE
			$Mesh/MuzzleFlash.rotation.z = randf_range(0.0, PI * 2.0)
			
			ammo -= 1
			item_name = base_item_name + " (" + str(ammo) + ")"
			player.set_item_label(str(ammo))
		
			GlobalAudio.play(gunshot_sound, 1.0, randf_range(0.95, 1.0))
		
			var camera: Camera3D = player.get_camera()
			
			var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - 100.0 * camera.global_transform.basis.z)
			var result = get_world_3d().direct_space_state.intersect_ray(query)
			
			if result and result.collider is Creature:
				result.collider.change_health(-damage)
		
		else:
			GlobalAudio.play(dryfire_sound, 1.0, randf_range(0.95, 1.0))
