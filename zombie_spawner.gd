extends Node3D

var ZOMBIE_TSCN: = preload("res://zombie.tscn")

@export var spawning_surface: StaticBody3D
@export var spawn_center: Node3D # typically the player

@export_category("Spawn Config")
@export_range(5, 100, 1, "or_greater") var min_spawn_distance: float = 25.0
@export_range(5, 100, 1, "or_greater") var max_spawn_distance: float = 50.0

## When a zombie is trying to spawn, if the number of zombies around its spawn
## location is greater than max_density - 1, it won't spawn.
@export_range(0, 100, 1, "or_greater") var max_density: int = 3
@export var spawn_rate_sec: int = 3

var spawn_attempt_timer: float = spawn_rate_sec

func _process(delta: float) -> void:
	
	spawn_attempt_timer -= delta
	
	if (spawn_attempt_timer < 0.0):
		
		spawn_attempt_timer = spawn_rate_sec
		
		var spawn_distance := lerpf(min_spawn_distance, max_spawn_distance, randf())
		
		var spawn_pos = spawn_center.global_position
		spawn_pos.y += 25.0
		var a = randf_range(0, PI * 2)
		spawn_pos.x += cos(a) * spawn_distance
		spawn_pos.z += sin(a) * spawn_distance
		var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(spawn_pos, spawn_pos + Vector3(0, -50, 0)))
		
		if (result and result.collider == spawning_surface):
			
			# check density
			var density := 0
			for child in get_children():
				if result.position.distance_to(child.position) < spawn_distance:
					density += 1
			
			if density < max_density:
				var zombie: Node3D = ZOMBIE_TSCN.instantiate()
				add_child(zombie)
				zombie.global_position = result.position
