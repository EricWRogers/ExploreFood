extends Area3D

var ingredient_type
@export var cook_timer_time: float = 1
func _on_body_entered(body: Node3D) -> void:
	if body.has_method("RollSpawn"): #checks if body is an ingredient. This check should be made better later.
		print("hi")
		body.queue_free()
		#spawn timer
		#on timer timeout, spawn ingredient again
