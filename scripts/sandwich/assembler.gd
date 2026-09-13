extends StaticBody3D

var timer_left = 100

func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()

func assemble():
	Manager.current_assembler = self
	Manager.player.alive = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Manager.assemblerui.show()
	Manager.assemblerui.snapshot()
	print("assemble")
	
func sandwich_start():
	timer_left = 100
	$Timer.start()
	$AnimationPlayer.play("assemble")
	$SubViewport/TextureProgressBar.value = timer_left

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false


func _on_timer_timeout() -> void:
	if timer_left > 0:
		timer_left -= 5
		$SubViewport/TextureProgressBar.value = timer_left
	else:
		$SubViewport/TextureProgressBar.value = 0
		$Timer.stop()
		$AnimationPlayer.play("RESET")
		self.set_collision_layer_value(10, true)
