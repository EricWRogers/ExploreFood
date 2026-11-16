extends Node

###
## this script is in charge of tracking what quests need to be given to the player and what dialogue needs to be outputted
###

#dialogue stuff(dated)
@export var dialogue_tree : Array[Dialogue] = []
var lines: Array[String] = []
var quest_item: String

#quests
@export var quests: Array[Quest] = []
@export var completion_text: Array[String]

var current_quest: Quest
var is_quest_given: bool = false
var current_quest_index: int = 0

#npc activation
var is_in_range: bool
var is_talking: bool

#UI
@onready var interact_ui: Node3D = $InteractUI

@export_category("spawns for tutorial")
@export var ingredient1: PackedScene
@export var ingredient2: PackedScene


func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("Interact")):
		if (!is_talking && is_in_range):
			interact_ui.hide()
			is_talking = true
			select_dialogue()


func _ready() -> void:
	interact_ui.hide()
	is_talking = false


## decide what dialogue should be be displayed
func select_dialogue():
	if (is_quest_given):
		DialogueManager.start_dialogue(current_quest.reminder)
		return
	elif ((current_quest_index >= quests.size()) || quests.size() == 0):
		DialogueManager.start_dialogue(completion_text)
		return
	
	# if there is no quest given and a quest avaliable, start new quest
	current_quest = quests[current_quest_index]
	DialogueManager.start_dialogue(current_quest.start_quest)
	is_quest_given = true


## turn in quest
func serve_dish():
	pass


## call dialogue manager, giving it an array of dialogue strs to iterate through
func _call_dialogue():
	# get data from dialogue resource
	lines = dialogue_tree[Manager.dialogue_tree_index].dialogue_lines #get string array
	quest_item = dialogue_tree[Manager.dialogue_tree_index].QuestItem #get quest item name
	
	DialogueManager.start_dialogue(lines, quest_item, Manager.dialogue_tree_index)
	
	# messy nasty code for proto quest. to be deleted.
	if (Manager.dialogue_tree_index == 0):
		print("index from 0 to 1")
		Manager.dialogue_tree_index = 1 #switch from tutorial activation to tutorial reminder
	elif (Manager.dialogue_tree_index == 2):
		print("index from 2 to 6")
		Manager.dialogue_tree_index = 6 #switch from quest activation to quest reminder 


##probably deleting soon 
##TEMPORARY quest manager. Might make into its own script?
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
				#spawn_tut()
			else:
				print("Pass tutorial")
				Manager.dialogue_tree_index = 2 ##pass tutorial
				
				## !! REMOVE TEMP !! ##
				$"../TempPortalManager".open_portal(1)
				
				Manager.current_quest_item = ""
				#remove tutorial wall
				$"../TutWall".visible = false
				$"../TutWall".use_collision = false
				Manager.is_tut_over = true
		elif (body.name == Manager.current_quest_item): 
			print("Correct! Scrumptious!")
			Manager.dialogue_tree_index = 4 ##pass quest
			
			## !! REMOVE TEMP !! ##
			$"../TempPortalManager".open_portal(2)
			
			Manager.current_quest_item = ""
		else:										
			print("Wrong wrong wrong! Horrible.")
			Manager.dialogue_tree_index = 5 ##fail quest
		
		_call_dialogue()
		body.queue_free()


##deleting soon. lol
func spawn_tut():
	var ingredient_spawn1: Node
	var ingredient_spawn2: Node
	var current_scene = get_tree().root
	
	ingredient_spawn1 = ingredient1.instantiate()
	ingredient_spawn1.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	current_scene.add_child(ingredient_spawn1)
	ingredient_spawn1.position = Vector3(2, 2.6, -0.25)
	#print ("tutorial is spawning: ", ingredient_spawn1)
	
	ingredient_spawn2 = ingredient2.instantiate()
	ingredient_spawn2.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	current_scene.add_child(ingredient_spawn2)
	ingredient_spawn2.position = Vector3(0.1, 2, 0.8)
	#print ("tutorial is spawning: ", ingredient_spawn2)


## player entering dialogue area
func _on_dialogue_area_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		#print("player in")
		interact_ui.show()
		is_in_range = true


## player leaving dialogue area
func _on_dialogue_area_body_exited(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		#print("player out")
		interact_ui.hide()
		is_in_range = false
		is_talking = false


func _on_quest_accept_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
