extends Node

@onready var text_box_scene = preload("uid://c6oge8t8wu2ag") #text_box.tscn

var dialogue_lines : Array[String] = []
var current_line_index = 0
var text_box
var text_box_position: Vector2
var is_dialogue_active = false
var can_advance_line = false
var quest: String

signal freeze_player()
signal unfreeze_player()

func _ready() -> void:
	pass
	#print("Yes, I see the dialogue manager")

func _process(_delta):	
	#progresses down the dialogue lines 
	if(
		Input.is_action_just_pressed("Interact") &&
		is_dialogue_active &&
		can_advance_line
	): 
		text_box.queue_free()
		
		current_line_index += 1
		
		#end dialogue
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			#set new quest if applicable
			if (quest != ""):
				_give_quest()
			#unfreeze player 
			unfreeze_player.emit()
			return
		else:
			show_text_box()

#dialogue starts here. Method called from npc dialogue
func start_dialogue(lines: Array[String], quest_item: String):
	if is_dialogue_active:
		return
	
	#freeze player 
	freeze_player.emit()
	
	#print(lines)
	dialogue_lines = lines
	quest = quest_item
	show_text_box()
	is_dialogue_active = true


#spawns and handles textbox
func show_text_box(): 
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(on_text_box_finished_displaying)
	get_tree().current_scene.add_child(text_box)
	
	text_box.display_text(dialogue_lines[current_line_index])
	#print("current line index: ", current_line_index)
	
	can_advance_line = false

func on_text_box_finished_displaying(): #emits signal from text box
	can_advance_line = true

#creates a new quest
func _give_quest():
	print("quest given!")
	Manager.current_quest_item = quest
	print("Quest item assigned: ", Manager.current_quest_item)
