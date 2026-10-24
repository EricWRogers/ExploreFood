extends StaticBody3D

var can_open = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_detect_area_body_entered(body: Node3D) -> void:
	if body.has_method("_setup_camera") and can_open:
		$OvenMeshInstance/KitchenStoveDoor/AnimationPlayer.play("open_close")


func _on_player_detect_area_body_exited(body: Node3D) -> void:
	if body.has_method("_setup_camera") and can_open:
		$OvenMeshInstance/KitchenStoveDoor/AnimationPlayer.play_backwards("open_close")
