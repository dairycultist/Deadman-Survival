extends RigidBody3D
class_name Item

@export var is_weapon: bool = false
@export var item_name: String = "unnamed"
@export var item_description: String = "No description."

func _ready() -> void:
	
	# uniquify material
	if $Mesh.material_override == null:
		$Mesh.material_override = $Mesh.surface_get_material(0).duplicate()
	else:
		$Mesh.material_override = $Mesh.material_override.duplicate()

func set_highlight(value: bool):
	
	# Change the albedo color property
	$Mesh.material_override.set("shader_parameter/highlight_amt", 1.0 if value else 0.0)

func mesh():
	return $Mesh

func set_rigidbody(value: bool):

	set_highlight(false)
	freeze = not value
	get_child(0).disabled = not value # collider

func process_when_held(_player: Node3D, _backpack: Node3D):
	pass
