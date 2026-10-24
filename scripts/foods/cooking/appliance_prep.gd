extends Node

###Applies prep tag to ingredients placed inside
##
@export_group("Appliance Settings")
@export var prep_group_application_type: BaseFood.PrepGroup
@onready var spawn_position: Marker3D = $SpawnMarker
@onready var player_detection: Area3D = $"../PlayerDetectArea"
var is_in_range: bool = false
var is_full: bool = false
var is_prepping: bool = false
var capacity: int = 0

@export_category("UI")
@export var station_ui : Control

@export_group("Timer Settings")
@export var prep_timer_time: float = 1
@onready var timer_ui: TextureProgressBar = $"../SubViewport/TextureProgressBar"
@onready var prep_timer: Timer = $PrepTimer

##ingredient settings
var saved_cook_group: BaseFood.CookGroup
var current_ingredient: PackedScene
var collected_ingredients : Array[PackedScene]

func _ready() -> void:
	if (timer_ui == null):
		push_error("Timer UI cannot be found!")
	timer_ui.visible = false
	%Prompts.hide()

func _process(_delta: float) -> void:
	timer_ui.value = 100 / prep_timer.time_left
	#print("cook timer time left: ", cook_timer.time_left)
	#print("timer ui", timer_ui.value)
	if (Input.is_action_just_pressed("cook") && is_in_range && collected_ingredients.size() >= 1):
		is_prepping = true
		start_prep_timer()
		#prep_all()
	if (Input.is_action_just_pressed("Reset") && is_in_range):
		return_ingredients()

##giving food
func _on_body_entered(body: Node3D) -> void:
	
	if (body.has_method("im_food") && !is_full): #checks if body is an ingredient. This check should be made better later.
		#print("yum, I found a food! is prepped: ", body.prep_group)
		if (body.prep_group != 0):
			print("can't take, it's already been prepped!")
		else:
			if station_ui.filled >= station_ui.capacity:
				return
			else:
				station_ui._update_visual(body.icon)

			#take ingredient data
			saved_cook_group = body.cook_group
			current_ingredient = load(body.scene_file_path)
			
			#add ingredient data to main array
			collected_ingredients.append(current_ingredient)
			
			#delete obj
			body.queue_free()
			
			##debugging lines
			#print("ingredient: ", current_ingredient)
			#print("collected ingredients:", collected_ingredients)
			
			#is_full = true
			#start_prep_timer()

func start_prep_timer():
	#set timer time
	timer_ui.visible = true
	station_ui.visible = false
	prep_timer.wait_time = prep_timer_time
	prep_timer.start()

func _on_prep_timer_timeout() -> void:
	print("prep timeout!")
	#animation here
	prep_all()
	timer_ui.visible = false
	station_ui.visible = true

##preps all ingredients in array
func prep_all():
	print("prepping...")
	for ingredient in collected_ingredients:
		var ingredient_spawn: Node
		#spawn back prepped ingredient
		var current_scene = get_tree().root
		ingredient_spawn = ingredient.instantiate()
		ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
		
		#add tags
		ingredient_spawn.prep_group = prep_group_application_type #Example: BaseFood.PrepGroup.CHOPPED
		ingredient_spawn.cook_group = saved_cook_group
		
		current_scene.add_child(ingredient_spawn)
		print ("spawning: ", ingredient_spawn)

		#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
		ingredient_spawn.position = spawn_position.global_position
		
		current_ingredient = null
	
	#clear vars for next ingredient
	is_full = false
	is_prepping = false
	collected_ingredients.clear()
	station_ui._reset_visual()

#func _on_prep_timer_timeout() -> void:
	#print("prep timeout!")
	#for ingredient in collected_ingredients:
		#var ingredient_spawn: Node
	#
		##spawn back prepped ingredient
		#var current_scene = get_tree().root
		#ingredient_spawn = current_ingredient.instantiate()
		#ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
		#current_scene.add_child(ingredient_spawn)
		#print ("spawning: ", ingredient_spawn)
	#
		##set prep tag
		#ingredient_spawn.is_prepped = true
		#
		##add tags
		#ingredient_spawn.prep_group = prep_group_application_type #Example: BaseFood.PrepGroup.CHOPPED
		#ingredient_spawn.cook_group = saved_cook_group
#
		##TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
		#ingredient_spawn.position = Vector3(0, 2, 0.1)
		#
		#current_ingredient = null
	#
	##clear vars for next ingredient
	#timer_ui.visible = false
	#is_full = false

##returns unprepped ingredients on reset
func return_ingredients():
	#spawn back prepped ingredient
	for ingredient in collected_ingredients:
		#spawn back prepped ingredient
		var ingredient_spawn: Node
		var current_scene = get_tree().root
		ingredient_spawn = ingredient.instantiate()
		ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
		ingredient_spawn.cook_group = saved_cook_group #add tags
		current_scene.add_child(ingredient_spawn)
		print ("spawning: ", ingredient_spawn)

		#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
		ingredient_spawn.position = spawn_position.global_position
		
		current_ingredient = null
	#clear data
	collected_ingredients.clear()
	station_ui._reset_visual()


func _on_player_detect_area_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		print("player in")
		is_in_range = true
		%Prompts.show()

func _on_player_detect_area_body_exited(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		print("player out")
		is_in_range = false
		%Prompts.hide()
