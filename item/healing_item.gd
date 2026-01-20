extends Item

@export var health_per_second: int = 1
@export var seconds_of_healing: int = 10

func _ready() -> void:
	
	super._ready()
	
	item_description = "Heals " + str(health_per_second * seconds_of_healing) + " HP over " + str(seconds_of_healing) + " seconds."
