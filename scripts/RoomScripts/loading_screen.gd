extends CanvasLayer

signal loading_screen_ready
@export var animation_player: AnimationPlayer

func play_in():
	$Control/Sprite2D.show()
	$AnimationPlayer.play("LoadSceenTransition")
	
func play_out():
	$AnimationPlayer.play("LoadScreenIn")
