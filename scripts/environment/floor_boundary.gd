extends Area3D

@export var spawn: Node3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.global_position = spawn.global_position
