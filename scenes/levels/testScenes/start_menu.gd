extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	$".".hide()
	pass # Replace with function body.


func _on_continue_pressed() -> void:
	pass # Not yet implimented


func _on_exit_pressed() -> void:
	get_tree().quit()
