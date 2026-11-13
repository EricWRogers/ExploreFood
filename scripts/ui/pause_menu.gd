extends Control

@onready var holder: Control = $Holder


var paused : bool = false;

	



func _input(event):
	if event.is_action_pressed("Exit") and Manager.player.can_pause:
		paused = !paused
		if paused:
			if holder != null:
				get_tree().paused = true
				holder.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			if holder != null:
				get_tree().paused = false
				holder.visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$Holder.visible = false


func _on_exit_pressed() -> void:
	get_tree().quit()
