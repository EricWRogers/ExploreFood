extends Node

#UI stuff
@onready var interact_ui: Node3D = $InteractUI

#dialogue stuff
@export var dialogue_tree : Array[Dialogue] = []
var lines: Array[String] = []
var quest_item: String

#checks for if dialogue can be selected
var isInRange: bool
var isDialogueSelected: bool

@export_category("spawns for tutorial")
@export var ingredient1: PackedScene
@export var ingredient2: PackedScene

func _ready() -> void:
	interact_ui.hide()
	isDialogueSelected = false
	
	##spawn tutorial ingredients
	if (!Manager.is_tut_over):
		spawn_tut()

func _process(_delta):	
	if(Input.is_action_just_pressed("Interact") && 
	!isDialogueSelected &&
	isInRange):
		interact_ui.hide()
		_call_dialogue()
		

func _call_dialogue():
	isDialogueSelected = true
	#get data from dialogue resource
	lines = dialogue_tree[Manager.dialogue_tree_index].dialogue_lines #get string array
	quest_item = dialogue_tree[Manager.dialogue_tree_index].QuestItem #get quest item name
	
	DialogueManager.start_dialogue(lines, quest_item, Manager.dialogue_tree_index)
	
	if (Manager.dialogue_tree_index == 0):
		print("index from 0 to 1")
		Manager.dialogue_tree_index = 1 #switch from tutorial activation to tutorial reminder
	elif (Manager.dialogue_tree_index == 2):
		print("index from 2 to 6")
		Manager.dialogue_tree_index = 6 #switch from quest activation to quest reminder 

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

#TEMPORARY quest manager. Might make into its own script?
func _on_quest_check_body_entered(body: Node3D) -> void:
	if (Manager.current_quest_item == ""): #if quest is null, nothing happens
		print("quest item null")
		return
	if (body.has_method("get_rolled")): #check that item is a meal
		print("body found")
		if (Manager.current_quest_item == "tutorial"): ##tutorial
			if (body.name == "DubiousMeal"):
				print("Fail tutorial")
				Manager.dialogue_tree_index = 3 ##fail tutorial
				spawn_tut()
			else:
				print("Pass tutorial")
				Manager.dialogue_tree_index = 2 ##pass tutorial
				$"../TempPortalManager".open_portal(1)
				Manager.current_quest_item = ""
				#remove tutorial wall
				$"../TutWall".visible = false
				$"../TutWall".use_collision = false
				Manager.is_tut_over = true
		elif (body.name == Manager.current_quest_item): 
			print("Correct! Scrumptious!")
			Manager.dialogue_tree_index = 4 ##pass quest
			$"../TempPortalManager".open_portal(2)
			Manager.current_quest_item = ""
		else:										
			print("Wrong wrong wrong! Horrible.")
			Manager.dialogue_tree_index = 5 ##fail quest
		
		_call_dialogue()
		body.queue_free()

func spawn_tut():
	var ingredient_spawn1: Node
	var ingredient_spawn2: Node
	var current_scene = get_tree().root
	
	ingredient_spawn1 = ingredient1.instantiate()
	ingredient_spawn1.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	current_scene.add_child(ingredient_spawn1)
	ingredient_spawn1.position = Vector3(2, 2.6, -0.25)
	print ("tutorial is spawning: ", ingredient_spawn1)
	
	ingredient_spawn2 = ingredient2.instantiate()
	ingredient_spawn2.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	current_scene.add_child(ingredient_spawn2)
	ingredient_spawn2.position = Vector3(0.1, 2, 0.8)
	print ("tutorial is spawning: ", ingredient_spawn2)
