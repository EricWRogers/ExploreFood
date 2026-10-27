extends MeshInstance3D

var cooking := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_detect_food_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ingredient") and not cooking:
		if body.can_be_cooked:
			cooking = true
			body._become_held($SpawnPnt)
			body.pan_grill()
			body.current_station = self
			$Sizzle.play()
			$AnimationPlayer.play("cooking")
func finished_cooking():
	$Sizzle.stop()
	$AnimationPlayer.stop()
	cooking = false
	$GPUParticles3D.hide()
	$Water.hide()
