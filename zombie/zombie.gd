extends Creature

@export var target: Creature # typically the player

@export_range(5, 100, 1, "or_greater") var aggro_range := 10.0
@export_range(5, 100, 1, "or_greater") var deaggro_range := 20.0
@export var drag := 8
@export var accel := 20

@export var idle_sound: AudioStream
@export var attack_sound: AudioStream

var aggroed := false
var attack_cooldown: float = 0.0

func change_health(amt: int):
	
	super.change_health(amt)
	
	if _health <= 0:
		queue_free()

func _process(delta: float) -> void:
	
	if aggroed:
		
		process_aggroed(delta)
		
		if target.global_position.distance_to(global_position) > deaggro_range:
			aggroed = false
		
	else:
		
		process_deaggroed(delta)
		
		if target.global_position.distance_to(global_position) < aggro_range:
			aggroed = true

func process_aggroed(delta: float) -> void:
	
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
	
	# random idle sound
	if not $Audio.playing and randi() % 2000 == 0:
		$Audio.stream = idle_sound
		$Audio.play()
	
	# attack target
	if attack_cooldown <= 0.0:
		
		# attack if close enough
		if target.global_position.distance_to(global_position) < 1.5:
			
			target.change_health(-randi_range(7, 12)) # I love hardcoding values
			attack_cooldown = randf_range(0.8, 1.0)
			
			$Audio.stream = attack_sound
			$Audio.play()
		
	else:
		attack_cooldown -= delta

func process_deaggroed(_delta: float) -> void:
	pass
