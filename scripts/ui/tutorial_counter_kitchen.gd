extends Node3D

func _ready() -> void:
	Manager.kitchen_tut += 1
	if Manager.kitchen_tut == 2 or Manager.kitchen_tut == 3:
		$"../SellingTutorial".show()
	elif Manager.kitchen_tut == 1:
		pass
	else:
		$"../SellingTutorial".hide()
