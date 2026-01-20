extends CharacterBody3D
class_name Creature

@export var _health: int = 100
## Sound that indicates to the player a hit was registered (like in CS);
## Distinct from diegetic hit sounds.
@export var hit_sound: AudioStream

var hit_audio: AudioStreamPlayer

func _ready() -> void:
	hit_audio = AudioStreamPlayer.new()
	add_child(hit_audio)
	hit_audio.stream = hit_sound

func change_health(amt: int):
	_health += amt
	hit_audio.play()
