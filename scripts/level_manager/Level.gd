extends Node

@export var level_name : String = "level"
signal level_changed(level_name)

func _on_portal_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		emit_signal("level_changed", level_name)
		
func switch():
	emit_signal("level_changed", level_name)
