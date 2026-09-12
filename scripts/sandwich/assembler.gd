extends StaticBody3D

func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false
