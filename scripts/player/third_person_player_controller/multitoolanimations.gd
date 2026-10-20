extends Node3D

var current_mode := 0

func _spoon():
	if current_mode == 0:
		return
	else:
		current_mode = 0
		%Switch.play("SwitchtoSpoon")
func _fork():
	if current_mode == 1:
		return
	else:
		current_mode = 1
		%Switch.play("SwitchtoFork")


func _on_switch_animation_finished(anim_name: StringName) -> void:
	if anim_name == "SwitchtoFork":
		%Glint.play("Glint")
