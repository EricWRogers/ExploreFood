extends Node3D

var cross_section_material = preload(
    "res://fp_scenes/kitchen/textures/Materials/MeatCrossSection.tres"
	
)

@export var knife: Node3D
@export var food_area: Area3D
@export var cut_bodies_parent: Node3D
@export var mapping_area: MeshInstance3D
@export var input_size: Vector2 = Vector2(400, 300)
@export var input_offset: Vector2 = Vector2.ZERO
@export var world_size: Vector2 = Vector2(0.5, 0.8)
@onready var knife_move: Node3D = $Kitchentable/KnifeMove
@export var move_speed: float = 10.0

var cutting = false
var anim = false

func get_custom_mouse_position() -> Vector2:
	var screen_size = get_viewport().get_visible_rect().size
	var input_origin = (screen_size - input_size) / 2.0
	input_origin += input_offset

	var mouse = get_viewport().get_mouse_position()
	var relative = mouse - input_origin

	return Vector2(
	-(relative.x / input_size.x - 0.5) * world_size.x,
	-(relative.y / input_size.y - 0.5) * world_size.y
	)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click"):
		_cut()

	$Decal.global_position.x = knife_move.global_position.x
	$Decal.global_position.z = knife_move.global_position.z

	var mapped_position = get_custom_mouse_position()
	var target_position = Vector3(
		mapped_position.x,
		knife_move.position.y,
		mapped_position.y
	)

	if !cutting:
		knife_move.position = knife_move.position.lerp(
			target_position,
			1.0 - exp(-move_speed * delta)
		)

func _cut():
	if !cutting:
		cutting = true
		anim = true
		$AnimationPlayer.play("Slice")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if cutting and anim:
		$AnimationPlayer.play_backwards("Slice")
		anim = false
	else:
		cutting = false

func cut_food() -> void:
	if !anim:
		return
	for body in food_area.get_overlapping_bodies().duplicate():
		if body is RigidBody3D:
			slice_body(body)


func slice_body(body: RigidBody3D) -> void:
	var meshinstance: MeshInstance3D = body.get_node("MeshInstance3D")

	# Convert the knife's transform into the mesh's local space.
	var slice_transform = (
		meshinstance.global_transform.affine_inverse()
		* knife.global_transform
	)

	# Slice the mesh.
	var meshes := MeshSlicer.slice_mesh(
		slice_transform,
		meshinstance.mesh,
		cross_section_material
	)

	if meshes.size() < 2 or meshes[0] == null or meshes[1] == null:
		return

	# Replace the original mesh with the first piece.
	meshinstance.mesh = meshes[0]

	var collision: CollisionShape3D = body.get_node("CollisionShape3D")

	if meshes[0].get_faces().size() > 2:
		collision.shape = meshes[0].create_convex_shape()

	# Recalculate center of mass.
	body.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	body.center_of_mass = body.to_local(
		meshinstance.to_global(calculate_center_of_mass(meshes[0]))
	)

	# Distribute mass according to estimated volume.
	var volume1 = calculate_mesh_volume(meshes[0])
	var volume2 = calculate_mesh_volume(meshes[1])
	var total_volume = volume1 + volume2

	if total_volume <= 0.0:
		return

	var original_mass = body.mass
	var mass1 = original_mass * (volume1 / total_volume)
	var mass2 = original_mass * (volume2 / total_volume)

	body.mass = mass1

	# Create the second piece.
	var body2 = body.duplicate() as RigidBody3D
	cut_bodies_parent.add_child(body2)
	body2.global_transform = body.global_transform

	var meshinstance2: MeshInstance3D = body2.get_node("MeshInstance3D")
	var collision2: CollisionShape3D = body2.get_node("CollisionShape3D")

	meshinstance2.mesh = meshes[1]
	body2.mass = mass2

	if meshes[1].get_faces().size() > 2:
		collision2.shape = meshes[1].create_convex_shape()

	# Remove pieces that are too small.
	var aabb1 = meshes[0].get_aabb()
	var aabb2 = meshes[1].get_aabb()

	if aabb2.size.length() < 0.3:
		body2.queue_free()

	if aabb1.size.length() < 0.3:
		body.queue_free()

	# Adjust the second piece's center of mass.
	body2.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	body2.center_of_mass = body2.to_local(
		meshinstance2.to_global(calculate_center_of_mass(meshes[1]))
	)


func calculate_center_of_mass(mesh: ArrayMesh) -> Vector3:
	var mesh_volume = 0.0
	var temp = Vector3.ZERO
	var faces = mesh.get_faces()

	for i in range(0, faces.size(), 3):
		if i + 2 >= faces.size():
			break

		var v1 = faces[i]
		var v2 = faces[i + 1]
		var v3 = faces[i + 2]

		var center = (v1 + v2 + v3) / 3.0
		var volume = (
			Geometry3D.get_closest_point_to_segment_uncapped(
				v3, v1, v2
			).distance_to(v3) * v1.distance_to(v2)
		) / 2.0

		mesh_volume += volume
		temp += center * volume

	if mesh_volume == 0.0:
		return Vector3.ZERO

	return temp / mesh_volume


func calculate_mesh_volume(mesh: ArrayMesh) -> float:
	var volume = 0.0

	for surface in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface)
		var vertices = arrays[Mesh.ARRAY_VERTEX]

		for i in range(0, vertices.size(), 3):
			var v1 = vertices[i]
			var v2 = vertices[i + 1]
			var v3 = vertices[i + 2]

			volume += abs(v1.dot(v2.cross(v3))) / 6.0

	return volume


	
