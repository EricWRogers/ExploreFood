extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var texture_pass := overlay.next_pass as ShaderMaterial
func change_color(color):
	var gradient = (
	(overlay)
	.next_pass
	.get_shader_parameter("mesh_texture")
	.gradient
	)
	#get_parent().current_top = $AttachPnt.position
	#var mat = $MeshInstance3D.mesh.surface_get_material(0)
	#mat.albedo_color = color
	var randx = randf_range(-2.0, 2.0)
	var randz = randf_range(-2.0, 2.0)
	$MeshInstance3D.rotation_degrees = Vector3(randx, 0, randz)
	# Assume 'my_gradient' is your Gradient resource
# Index 0 is typically the first color handle
	gradient.set_color(0, color) 
