extends Node

var _sources: Array[AudioStreamPlayer]
var _available_source_index: int = 0

var _sources_3D: Array[AudioStreamPlayer3D]
var _available_source_3D_index: int = 0

func _ready() -> void:
	
	_sources    = [ AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new() ]
	_sources_3D = [ AudioStreamPlayer3D.new(), AudioStreamPlayer3D.new(), AudioStreamPlayer3D.new() ]
	
	for source in _sources:
		get_tree().root.get_child(0).add_child(source)

func play(sound: AudioStream, volume: float = 1.0, pitch: float = 1.0):
	
	var source := _sources[_available_source_index]
	_available_source_index = (_available_source_index + 1) % _sources.size()
	
	source.stream = sound
	source.volume_linear = volume
	source.pitch_scale = pitch
	source.play()

func play_at(sound: AudioStream, position: Vector3, volume: float = 1.0, pitch: float = 1.0):
	
	var source := _sources_3D[_available_source_index]
	_available_source_3D_index = (_available_source_3D_index + 1) % _sources_3D.size()
	
	source.stream = sound
	source.volume_linear = volume
	source.pitch_scale = pitch
	source.global_position = position
	source.play()
