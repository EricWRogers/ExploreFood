extends Node3D

func _ready() -> void:
	Manager.kitchen = self
	Manager.kitchen_tut += 1
	if Manager.kitchen_tut == 2 or Manager.kitchen_tut == 3:
		$"../SellingTutorial".show()
	elif Manager.kitchen_tut == 1:
		pass
	else:
		$"../SellingTutorial".hide()
	
func showwaffle():
	$"../AnimationPlayer".play("waffledim")
	$"../WaffleDimension".make_current()
func showmeat():
	$"../AnimationPlayer".play("sell")
	$"../Selling".make_current()
func showsell():
	$"../AnimationPlayer".play("meatdim")
	$"../MeatPieDimension".make_current()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$"../Player/CharacterBody3D/Head/Camera3D".make_current()
