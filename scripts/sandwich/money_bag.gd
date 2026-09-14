extends RigidBody3D

@export var type: String
var value = 10
var assessing = false

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
