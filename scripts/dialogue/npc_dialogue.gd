class_name NPC extends Node

###
## this script is in charge of tracking what quests need to be given to the player and what dialogue needs to be outputted
###

#quests
@export var quests: Array[Quest] = []
@export var completion_text: Array[String]

var current_quest: Quest
var is_quest_given: bool = false
var current_quest_index: int = 0

#friendship
var friendship: int = 0

#dialogue activation
var is_in_range: bool
var is_talking: bool

#UI
@onready var interact_ui: Node3D = $InteractUI

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
	if (is_quest_given): # if a quest is active, show reminder text
		DialogueManager.start_dialogue(current_quest.reminder) 
		return
	elif ((current_quest_index >= quests.size()) || quests.size() == 0): # if no new quests are avaliable, play completion text
		DialogueManager.start_dialogue(completion_text)
		return
	
	# if there is no quest given and a quest avaliable, start new quest
	start_quest()


func start_quest():
	current_quest = quests[current_quest_index]
	is_quest_given = true
	DialogueManager.start_dialogue(current_quest.start_quest)


## turn in quest
func serve_dish(dish_name: String):
	is_talking = true
	#print("current quest item: ", current_quest.quest_item)
	if (dish_name != current_quest.quest_item): # if the item is wrong, fail quest
		DialogueManager.start_dialogue(current_quest.fail_quest)
		return
	
	# if item is right, pass test!
	DialogueManager.start_dialogue(current_quest.pass_quest)
	friendship += 1
	current_quest_index += 1
	is_quest_given = false


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
	if (is_quest_given && body.is_in_group("Item")):
		#print("body: ", body.scene_file_path)
		serve_dish(body.scene_file_path)
		body.queue_free()
