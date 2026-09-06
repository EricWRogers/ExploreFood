extends Button

@export var info_to_pull : String
@export var hover_target : Control

func _on_pressed() -> void:
	$"../../../../../../../..".set_info(info_to_pull)


func _on_mouse_entered() -> void:
	hover_target.pivot_offset_ratio = Vector2(0.5, 0.5)
	var tween = create_tween()
	hover_target.modulate = Color(Color(1.512, 1.512, 1.512))
	tween.tween_property(hover_target, "rotation_degrees", 5, 0.05)


func _on_mouse_exited() -> void:
	var tween = create_tween()
	hover_target.modulate = Color(1.0, 1.0, 1.0, 1.0)
	tween.tween_property(hover_target, "rotation_degrees", 0, 0.05)


func _on_button_down() -> void:
	var tween = create_tween()
	hover_target.pivot_offset_ratio = Vector2(0.5, 0.5)
	tween.tween_property(hover_target, "scale", Vector2(0.92, 0.92), 0.05)


func _on_button_up() -> void:
	var tween = create_tween()
	hover_target.pivot_offset_ratio = Vector2(0.5, 0.5)
	tween.tween_property(hover_target, "scale", Vector2(1, 1), 0.05)
