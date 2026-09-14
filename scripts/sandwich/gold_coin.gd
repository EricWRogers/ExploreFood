extends RigidBody3D

@export var type = "coin"

func absorb():
	queue_free()
