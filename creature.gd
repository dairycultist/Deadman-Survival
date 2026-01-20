extends CharacterBody3D
class_name Creature

@export var _health: int = 100
@export var _max_health: int = 100
## Sound that indicates to the player a hit was registered (like in CS);
## Distinct from diegetic hit sounds as it is played by a non-positional
## audio source.
@export var hit_sound: AudioStream

func change_health(amt: int) -> int: # returns amt it actually changed by
	
	amt = min(amt, _max_health - _health)
	
	_health += amt
	
	if amt < 0:
		GlobalAudio.play(hit_sound)
	
	return amt
