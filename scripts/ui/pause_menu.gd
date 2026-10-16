extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("Pause"):
		$Holder.visible = true
		get_tree().paused = true

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$Holder.visible = false


func _on_exit_pressed() -> void:
	get_tree().quit()
