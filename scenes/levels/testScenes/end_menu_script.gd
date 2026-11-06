extends Control

var lock_mouse : bool = true
#thank you Crow
func back_to_start() -> void:
	
	# load starting scene from level manager
	Manager.level_manager.load_scene(Manager.level_manager.start_manu)
	print("going back to start menu")

	$".".hide()

func show_end_menu():
	pass
