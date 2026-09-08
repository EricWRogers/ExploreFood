extends Node

#UI stuff
@onready var interact_ui: Node3D = $InteractUI

#dialogue stuff
@export var dialogue_tree : Array[Dialogue] = []
@export var dialogue_tree_index : = 0
var lines: Array[String] = []
var quest_item: String

#checks for if dialogue can be selected
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
		
		#get data from dialogue resource
		lines = dialogue_tree[dialogue_tree_index].dialogue_lines #get string array
		quest_item = dialogue_tree[dialogue_tree_index].QuestItem #get quest item name
		dialogue_tree_index = 1 #switch from quest activation dialogue to quest reminder dialogue
		
		DialogueManager.start_dialogue(lines, quest_item)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		print("player in")
		interact_ui.show()
		isInRange = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		print("player out")
		interact_ui.hide()
		isInRange = false
		isDialogueSelected = false

#quest manager. Might make into its own script?
func _on_table_area_body_entered(body: Node3D) -> void:
	if (Manager.current_quest_item == ""): #if quest is null, nothing happens
		print("quest item null")
		return
	print("body found")
	if body.has_method("get_rolled"): #check that item is food
		if (body.name == Manager.current_quest_item): #pass quest
			print("correct! Scrumptious!")
			dialogue_tree_index = 2 #pass
			Manager.current_quest_item = ""
		else:										#fail quest
			print("Wrong wrong wrong! Horrible.")
			dialogue_tree_index = 3 #fail
		body.queue_free()
