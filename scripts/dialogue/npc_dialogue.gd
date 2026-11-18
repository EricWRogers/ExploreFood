class_name NPC extends Node

###
## this script is in charge of tracking what quests need to be given to the player and what dialogue needs to be outputted
###

#save data
@export var npc_resource: BaseNpc
static var data: BaseNpc

#quests
@export var quests: Array[Quest] = []
@export var completion_text: Array[String]

@onready var current_quest: Quest
@onready var current_quest_index: int
@onready var is_quest_given: bool

#friendship
@onready var friendship: int

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
	if (npc_resource == null):
		printerr("ERROR: NPC is missing data resource!")
		return
	
	if (data == null):
		data = npc_resource
	
	load_npc_data()
	
	#print("current quest = ", current_quest)
	#print("current quest index = ", current_quest_index)
	#print("is quest given? = ", is_quest_given)
	#print("friendship = ", friendship)
	
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
	save_npc_data()


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
	save_npc_data()


func save_npc_data():
	data.current_quest = current_quest
	data.current_quest_index = current_quest_index
	data.is_quest_given = is_quest_given
	data.friendship = friendship

func load_npc_data():
	current_quest = data.current_quest
	current_quest_index = data.current_quest_index
	is_quest_given = data.is_quest_given
	friendship = data.friendship

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
	if (data.is_quest_given && body.is_in_group("Item")):
		#print("body: ", body.scene_file_path)
		serve_dish(body.scene_file_path)
		body.queue_free()
