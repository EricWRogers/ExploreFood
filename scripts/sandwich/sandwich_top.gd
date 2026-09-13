extends Node3D

var in_chain = false
var my_leader
var lag_amnt = 1

func _physics_process(delta: float) -> void:
	if in_chain:
		global_position = global_position.lerp(my_leader.global_position, lag_amnt)
