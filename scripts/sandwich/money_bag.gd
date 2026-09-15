extends RigidBody3D

@export var type: String
var value = 10
var assessing = false
var holder
var held = false

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

func _on_body_entered(body: Node) -> void:
	if assessing == false:
		if body.has_method("absorb"):
			assessing = true
			print("ITOUCHEDABAGANDILIKEDIT")
			if body.type == "coin":
				body.absorb()
				value += 1
				assessing = false
				$Node3D/Label3D.text = str("$", value)
				return
			if self.get_instance_id() > body.get_instance_id():
				value += body.value
				body.absorb()
				assessing = false
				$Node3D/Label3D.text = str("$", value)
			else:
				pass
		
func absorb():
	queue_free()
	
func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D2.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D2.hide()


func _on_timer_timeout() -> void:
	self.set_collision_layer_value(1, true)
	self.set_collision_mask_value(1, true)
