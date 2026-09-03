extends Node3D


func snap_up():
	$AnimationPlayer.play("Devour")
	$WormHandle/YumChomp.bite()


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.has_method("dropthrow"):
		snap_up()
