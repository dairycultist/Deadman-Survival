extends Item

@export var health_per_second: int = 1
@export var seconds_of_healing: int = 10

var thread: Thread

func _ready() -> void:
	super._ready()
	item_description = "Heals " + str(health_per_second * seconds_of_healing) + " HP over " + str(seconds_of_healing) + " seconds."

func process_when_held(_delta: float, player: Creature):
	
	if Input.is_action_just_pressed("fire"):
	
		thread = Thread.new()
	
		if thread.start(_apply_healing.bind(player)) != OK:
			printerr("Could not start thread.")
		else:
			
			# just move the item somewhere far away while it heals the player
			reparent(get_tree().root.get_child(0))
			global_position = Vector3.ZERO

func _apply_healing(player: Creature):
	
	for i in range(seconds_of_healing):
		OS.delay_msec(1000)
		player.call_deferred("change_health", health_per_second)
	
	call_deferred("_finish_healing")

func _finish_healing():
	
	thread.wait_to_finish()
	queue_free()
