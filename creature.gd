extends CharacterBody3D
class_name Creature

@export var _health: int = 100
@export var _max_health: int = 100
## Sound that indicates to the player a hit was registered (like in CS);
## Distinct from diegetic hit sounds as it is played by a non-positional
## audio source.
@export var hit_sound: AudioStream

func _ready() -> void:
	
	# creatures are collision layer 2; they collide with themselves and the
	# terrain (collision layer 1), but not items
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)

func change_health(amt: int) -> int: # returns amt it actually changed by
	
	amt = min(amt, _max_health - _health)
	
	_health += amt
	
	if amt < 0:
		GlobalAudio.play(hit_sound)
	
	return amt
