extends CanvasLayer

#signal loading_screen_ready

@export var animation_player: AnimationPlayer

func play_in():
	$Control/Sprite2D.show()
	$AnimationPlayer.play("LoadSceenTransition")
	
func play_out():
	$AnimationPlayer.play("LoadScreenIn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "LoadScreenIn":
		Manager.player.start_hunger()
