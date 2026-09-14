extends Node3D

var my_assembler : StaticBody3D
var held = false
var exploded = false

func on_picked():
	if Manager.held_sandwich:
		return
	Manager.held_sandwich = self
	my_assembler.held_sandwich = null
	my_assembler = null
	held = true
	await get_tree().create_timer(0.1).timeout
	$RayCast3D.enabled = true
	
func _physics_process(delta: float) -> void:
	if !exploded:
		if $RayCast3D.is_colliding():
			var body = $RayCast3D.get_collider()
			if body.get_collision_layer_value(11):
				return
				exploded = true
			exploded = true
			print("EXPLODING TIME")
			get_tree().call_group("SandwichPiece", "explode", self)
			queue_free()
	if !held:
		return
	var tween = create_tween()
	tween.tween_property(self, "global_position", Manager.player_hold.global_position, 0.001)
	
