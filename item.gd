extends RigidBody3D
class_name Item

@export var is_weapon: bool = false

func _ready() -> void:
	
	# uniquify material
	if $Mesh.material_override == null:
		$Mesh.material_override = $Mesh.surface_get_material(0).duplicate()
	else:
		$Mesh.material_override = $Mesh.material_override.duplicate()

func set_highlight(value: bool):
	# Change the albedo color property
	$Mesh.material_override.set("shader_parameter/highlight_amt", 1.0 if value else 0.0)

func process_when_held(player: Node3D):
	pass
