extends RigidBody3D

@export var type = "coin"
var held = false

var value = 10
var assessing = false
var holder

func _physics_process(delta: float) -> void:
	if !holder:
		return
	else:
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(1, false)
		rotation = Vector3.ZERO
		freeze = true
		Manager.held_sandwich = self
		global_position = holder.global_position

func absorb():
	queue_free()

func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()
	
func _on_timer_timeout() -> void:
	self.set_collision_layer_value(1, true)
	self.set_collision_mask_value(1, true)
