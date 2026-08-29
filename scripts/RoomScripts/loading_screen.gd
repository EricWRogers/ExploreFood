extends CanvasLayer

signal loading_sceen_ready
@export var animation_player: AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	loading_sceen_ready.emit()
	
func _on_progress_changed(new_value: float) -> void:
	pass #we can do somthing fncy here like a progress bar
	
func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
