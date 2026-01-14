extends Node3D

# when a zombie is trying to spawn, if the number of zombies around the spawn
# location is greater than max_density - 1, it won't spawn
@export var max_density: int = 3
@export var spawning_surface: StaticBody3D

func _process(delta: float) -> void:
	pass
