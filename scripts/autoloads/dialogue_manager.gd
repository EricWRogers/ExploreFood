extends Node

@onready var text_box_scene = preload("uid://c6oge8t8wu2ag") #text_box.tscn

var dialogue_lines : Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialogue_active = false
var can_advance_line = false

var _is_audrey: bool

func _ready() -> void:
	print("Yes, I see the dialogue manager")

func start_dialogue(lines: Array[String], is_audrey: bool):
	if is_dialogue_active:
		return
	
	print("dialogue activated")
	
	dialogue_lines = lines
	_is_audrey = is_audrey
	#text_box_position = position
	show_text_box()
	is_dialogue_active = true

#This is what actually displays dialogue!
func show_text_box(): 
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	#text_box.global_position = text_box_position
	text_box.display_text(dialogue_lines[current_line_index])
	
	print("current line index: ", current_line_index)
	
	can_advance_line = false

func on_text_box_finished_displaying():
	can_advance_line = true

func _process(_delta):	
	if(
		Input.is_action_just_pressed("Interact") &&
		is_dialogue_active &&
		can_advance_line
	):
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			if (_is_audrey):
				_give_quest()
			return
		else:
			show_text_box()

func _give_quest():
	print("quest given!")
