extends Node

@onready var current_level = $Kitchen
@export var CalebMode : bool = false
var to_go
var scene_switch_setter = false

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "start_loading"))
	
func start_loading(level):
	$LoadingScreen.play_in()
	to_go = level
	
func exit_loading():
	$LoadingScreen.play_out()

func _handle_level_change(current_level_name: String):
	var next_level
	var next_level_name
	
	#loads one level according to current level name. Will need to call random levels instead
	match current_level_name: 
		"kitchen":
			next_level_name = "terrain_test"
		"terrain_test":
			next_level_name = "kitchen"
	var temp = load("res://scenes/levels/"+ next_level_name + ".tscn") #creates packed scene
	next_level = temp.instantiate()
	call_deferred("add_child", next_level)
	next_level.connect("level_changed", start_loading)
	current_level.queue_free()
	current_level = next_level
	scene_switch_setter = false
	$Timer.start()


func _on_timer_timeout() -> void:
	if scene_switch_setter == false:
		var current_fps = Engine.get_frames_per_second()
		if current_fps >= 30:
			exit_loading()
			scene_switch_setter = true
			$Timer.stop()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "LoadSceenTransition":
		_handle_level_change(to_go)
