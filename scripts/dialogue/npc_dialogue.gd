extends Node

@export var dialogue_tree : Array[Dialogue] = []
@export var dialogue_tree_index : int

var lines: Array[String] = []
var quest_item: PackedScene
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
		lines = dialogue_tree[0].dialogue_lines
		quest_item = dialogue_tree[0].QuestItem
		
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
	if (Manager.current_quest_item == null):
		return
			
	#print("body detected: ", body)
	
	if body.has_method("get_rolled"):
		#print("i can tell this is a meal")
		print("body data: ", body.scene_file_path)
		print("manager quest data: ", Manager.current_quest_item.to_string())
		
		if (body.scene_file_path == Manager.current_quest_item.to_string()):
			print("correct! Scrumptious!")
		else:
			print("Wrong wrong wrong! Horrible.")
