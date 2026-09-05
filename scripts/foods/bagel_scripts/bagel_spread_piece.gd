extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var texture_pass := overlay.next_pass as ShaderMaterial

func change_color(color):
	var mat = $MeshInstance3D.get_surface_override_material(0).duplicate(true)
	mat.albedo_color = color
	$MeshInstance3D.set_surface_override_material(0, mat)
	var randx = randf_range(-2.0, 2.0)
	var randz = randf_range(-2.0, 2.0)
	$MeshInstance3D.rotation_degrees = Vector3(randx, 0, randz)
	# Assume 'my_gradient' is your Gradient resource
# Index 0 is typically the first color handle
