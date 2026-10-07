extends StaticBody3D
signal rush_button_hit

# Called when the node enters the scene tree for the first time.
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
