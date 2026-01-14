extends CharacterBody3D

@export var mouse_sensitivity := 0.3
@export var drag := 8
@export var accel := 50

var camera_pitch := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CameraAnchor/Backpack.visible = false

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x += direction.x * accel * delta
		velocity.z += direction.z * accel * delta
	
	velocity += get_gravity() * 2.5 * delta
	velocity = lerp(velocity, Vector3.ZERO, delta * drag)
	
	move_and_slide()

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$CameraAnchor/Backpack.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$CameraAnchor/Backpack.visible = false
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)
