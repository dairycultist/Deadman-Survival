extends Node3D

@export var center: Node3D # the player (so we can always sit right below them)

func _process(_delta: float) -> void:
	global_position.x = center.global_position.x
	global_position.z = center.global_position.z
