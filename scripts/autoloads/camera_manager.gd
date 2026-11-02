extends Node

@onready var regular_camera: Camera3D = $Camera3D
@onready var phantom_camera: PhantomCamera3D = $PhantomCamera3D


func switch_to_regular():
	for cam in get_tree().get_nodes_in_group("Camera"):
		if cam.name != "Player":
			cam.set_priority(0)
		else:
			cam.set_priority(1)
	#regular_camera.make_current()
func switch_to_oven():
	for cam in get_tree().get_nodes_in_group("Camera"):
		if cam.name != "Oven":
			cam.set_priority(0)
		else:
			cam.set_priority(1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switch_to_regular()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
