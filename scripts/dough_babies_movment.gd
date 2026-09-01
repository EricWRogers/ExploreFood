extends Node3D

const MOVE_SPEED = 16

func _physics_process(delta: float) -> void:
	$Path1/PathFollow3D.progress += MOVE_SPEED * delta;
	$Path2/PathFollow3D.progress += MOVE_SPEED * delta;
