extends CharacterBody3D

@export var target: Node3D # typically the player

@export_range(5, 100, 1, "or_greater") var aggro_range := 10.0
@export_range(5, 100, 1, "or_greater") var deaggro_range := 20.0
@export var drag := 8
@export var accel := 20

var aggroed := false

func _process(delta: float) -> void:
	
	if aggroed:
		
		# face toward player
		var target_position = target.global_position
		target_position.y = global_position.y
		look_at(target_position)
		
		# move forward
		velocity.x += -transform.basis.z.x * accel * delta
		velocity.z += -transform.basis.z.z * accel * delta
		
		velocity += get_gravity() * 2.5 * delta
		velocity = lerp(velocity, Vector3.ZERO, delta * drag)
		
		move_and_slide()
		
		if target.global_position.distance_to(global_position) > deaggro_range:
			aggroed = false
		
	else:
		
		if target.global_position.distance_to(global_position) < aggro_range:
			aggroed = true
