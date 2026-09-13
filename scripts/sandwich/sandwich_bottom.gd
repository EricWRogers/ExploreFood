extends Node3D

var my_assembler : StaticBody3D
var held = false

func on_picked():
	my_assembler.held_sandwich = null
	my_assembler = null
	held = true
	
func _physics_process(delta: float) -> void:
	if !held:
		return
	var tween = create_tween()
	tween.tween_property(self, "global_position", Manager.player_hold.global_position, 0.001)
