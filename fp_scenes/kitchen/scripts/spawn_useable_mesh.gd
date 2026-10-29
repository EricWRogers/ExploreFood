extends Node3D

var spawn = preload("res://fp_scenes/kitchen/scenes/cutting_table_rigid.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_detect_ingredient_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ingredient"):
		var mat = body.material
		var mesh = body.get_child(0).original_mesh
		#body.queue_free()
		var ing = spawn.instantiate()
		get_tree().current_scene.add_child(ing)
		ing.global_position = $"../FoodSpawn".global_position

		var ing_mesh: MeshInstance3D = ing.get_node("MeshInstance3D")
		ing_mesh.scale = body.resize
		ing_mesh.mesh = mesh
		#var new_mesh: ArrayMesh = mesh.duplicate()
		print(mat)
		var new_mat = StandardMaterial3D.new()
		new_mat.albedo_texture = mat
		ing_mesh.mesh.surface_set_material(0, new_mat)

		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = mesh.create_convex_shape()
		ing.add_child(collision_shape)

		collision_shape.position = ing_mesh.position
		collision_shape.rotation = ing_mesh.rotation
		collision_shape.scale = ing_mesh.scale
		collision_shape.name = "CollisionShape3D"
		body.queue_free()
