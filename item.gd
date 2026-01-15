extends RigidBody3D
class_name Item

@export var is_weapon: bool = false

func _ready() -> void:
	
	# uniquify material
	if $Mesh.material_override == null:
		var material = $Mesh.surface_get_material(0).duplicate()
		$Mesh.material_override = material

func set_highlight(value: bool):
	# Change the albedo color property
	$Mesh.material_override.set("shader_parameter/highlight_amt", 1.0 if value else 0.0)
