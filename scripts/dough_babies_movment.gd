extends Node3D

const MOVE_SPEED = 4.0

func _physics_process(delta: float) -> void:
	$Path1/PathFollow3D.progress += MOVE_SPEED * delta;
	$Path2/PathFollow3D.progress += MOVE_SPEED * delta;
