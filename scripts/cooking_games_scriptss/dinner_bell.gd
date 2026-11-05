extends StaticBody3D
signal rush_button_hit

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

var player_close = false;
func _process(delta: float) -> void:
	if player_close and Input.is_action_just_pressed("Interact"):
		rush_button_hit.emit()
	
func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	if ($Node3D == null):
		return
	
	$Node3D.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	if ( $Node3D== null):
		return
	
	$Node3D.hide()

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false
func start_rush_hour():
	rush_button_hit.emit()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !Manager.player_unlocked_recipes.is_empty():
		on_looked_at()
		player_close = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		on_looked_away()
		player_close = false
