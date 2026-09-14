extends RigidBody3D

var in_chain = false
var my_leader
var lag_amnt = 1
var impulse_force = 20
var original_bun

func _physics_process(delta: float) -> void:
	if in_chain:
		global_position = global_position.lerp(my_leader.global_position, lag_amnt)
func explode(caller):
	if caller == original_bun:
		self.set_collision_layer_value(1, true)
		self.set_collision_mask_value(1, true)
		in_chain = false
		self.freeze = false
		var random_dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		var impulse_vector = random_dir * impulse_force
		apply_central_impulse(impulse_vector)
		queue_free()
