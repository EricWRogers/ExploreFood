extends Control

#const dinerLvlTest = preload("res://scenes/levels/testScenes/DinerLevel_test.tscn")
#signal starting_game()
var started : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	started = true
	
	# load starting scene from level manager
	Manager.level_manager.load_scene(Manager.level_manager.starting_scene)
	print("loading scene: ", Manager.level_manager.starting_scene)
	
	#var load_scene = dinerLvlTest.instantiate()
	
	#starting_game.emit(load_scene) #emits signal to level manager
	
	#load_scene.connect("start_game", Callable(self, "game_started"))
	#emit_signal("start_game") 
	
	#add_sibling(load_scene)
	
	#print(load_scene)
	$".".hide()


func _on_continue_pressed() -> void:
	pass # Not yet implimented


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	started = true
	
	# load starting scene from level manager
	Manager.level_manager.load_scene(Manager.level_manager.starting_scene)
	print("loading scene: ", Manager.level_manager.starting_scene)
	$".".hide()


func _on_new_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
