extends Control



var lock_mouse : bool = true

func _on_node_status_changed(new_state: bool) -> void:
	lock_mouse = new_state
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("Pause"):
		if $Holder.visible == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$Holder.visible = true
			get_tree().paused = true
		else:
			get_tree().paused = false
			$Holder.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if Input.is_action_pressed("Exit"):
		lock_mouse = !lock_mouse
		if lock_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$Holder.visible = false


func _on_exit_pressed() -> void:
	get_tree().quit()
