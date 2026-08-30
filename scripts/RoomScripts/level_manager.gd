extends Node

@onready var current_level = $Kitchen

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "_handle_level_change"))

func _handle_level_change(current_level_name: String):
	var next_level
	var next_level_name
	
	#loads one level according to current level name. Will need to call random levels instead
	match current_level_name: 
		"kitchen":
			next_level_name = "terrain_test"
		"terrain_test":
			next_level_name = "kitchen"
		_: #error return
			return
	var temp = load("res://scenes/levels/"+ next_level_name + ".tscn") #creates packed scene
	next_level = temp.instantiate()
	call_deferred("add_child", next_level) 
	next_level.connect("level_changed", _handle_level_change)
	current_level.queue_free()
	current_level = next_level
