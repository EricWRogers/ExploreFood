extends Node3D

const NORMAL = preload("uid://u64weibhhadt")
const UNDER_WATER = preload("uid://cfm4o8d038ox3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for cam in get_tree().get_nodes_in_group("Camera"):
		if cam.name == "Player":
			if cam.global_position.y <= -3.59862875938416:
				$WorldEnvironment.environment = UNDER_WATER
			else:
				$WorldEnvironment.environment = NORMAL
			
