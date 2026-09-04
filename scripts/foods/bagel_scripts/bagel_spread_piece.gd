extends Node3D

func change_color(color):
	#get_parent().current_top = $AttachPnt.position
	var mat = $MeshInstance3D.mesh.surface_get_material(0)
	mat.albedo_color = color
	var randx = randf_range(-2.0, 2.0)
	var randz = randf_range(-2.0, 2.0)
	$MeshInstance3D.rotation_degrees = Vector3(randx, 0, randz)
