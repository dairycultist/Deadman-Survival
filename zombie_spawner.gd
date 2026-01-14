extends Node3D

@export var spawning_surface: StaticBody3D
@export var spawn_center: Node3D # typically the player

# when a zombie is trying to spawn, if the number of zombies around the spawn
# location is greater than max_density - 1, it won't spawn
@export var max_density: int = 3
@export var spawn_rate_sec: int = 3

var spawn_attempt_timer: float = spawn_rate_sec

func _process(delta: float) -> void:
	
	spawn_attempt_timer -= delta
	
	if (spawn_attempt_timer < 0.0):
		
		spawn_attempt_timer = spawn_rate_sec
		
		var spawn_pos = spawn_center.global_position
		spawn_pos.y += 25.0
		var a = randf_range(0, PI * 2)
		spawn_pos.x += cos(a) * 25.0
		spawn_pos.z += sin(a) * 25.0
		var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(spawn_pos, spawn_pos + Vector3(0, -50, 0)))
		
		if (result and result.collider == spawning_surface):
			print(result.position)
