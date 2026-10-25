extends Node3D


func appear(color):
	$Fade.wait_time = randi_range(2, 5)
	$Decal.rotation_degrees.y = randi_range(0, 360)
	$Decal.modulate = color
	$AnimationPlayer.play("splatter")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "splatter":
		$Fade.start()
	if anim_name == "fade":
		queue_free()


func _on_fade_timeout() -> void:
	$AnimationPlayer.play("fade")
