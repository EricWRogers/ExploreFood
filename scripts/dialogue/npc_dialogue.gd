extends Node

@export var dialogue_tree : Array[Dialogue] = []
@export var dialogue_tree_index : = 0

var lines: Array[String] = []
var quest_item: String
@export var ui_position: Vector2
@onready var interact_ui: Node3D = $InteractUI
var isInRange: bool
var isDialogueSelected: bool


func _ready() -> void:
	interact_ui.hide()
	isDialogueSelected = false

func _process(_delta):	
	if(Input.is_action_just_pressed("Interact") && 
	!isDialogueSelected &&
	isInRange):
		interact_ui.hide()
		isDialogueSelected = true
		
		#get data from resource
		lines = dialogue_tree[dialogue_tree_index].dialogue_lines
		quest_item = dialogue_tree[dialogue_tree_index].QuestItem
		
		DialogueManager.start_dialogue(lines, quest_item)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		interact_ui.show()
		isInRange = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		interact_ui.hide()
		isInRange = true
		isDialogueSelected = false


func _on_table_area_body_entered(body: Node3D) -> void:
	if (Manager.current_quest_item == ""): #if quest is null, nothing happens
		return
	
	if body.has_method("get_rolled"): #check that item is food
		if (body.name == Manager.current_quest_item):
			print("correct! Scrumptious!")
			dialogue_tree_index = 1 #pass
		else:
			print("Wrong wrong wrong! Horrible.")
			dialogue_tree_index = 2 #fail
		body.queue_free()
