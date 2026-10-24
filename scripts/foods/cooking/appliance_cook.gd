extends Node

##Applies cooking tag to ingredients placed inside
##if ingredients make a valid meal, it will output that meal instead
##

@export_group("Appliance Settings")
@export var cook_group_application_type: BaseFood.CookGroup
var is_in_range: bool = false
var is_full: bool = false
var is_cooking: bool
#var capacity: int = 0

@export_group("Saved Recipes")
@export var recipes : Array[Resource]

@export_group("UI and animation")
@export var idle_mesh: MeshInstance3D
@export var animation_mesh: Node3D
@export var animation: AnimationPlayer
@export var station_ui : Control
@onready var spawn_position: Marker3D = $SpawnMarker
@onready var player_detection: Area3D = $"../PlayerDetectArea"
#@onready var animation: AnimationPlayer = $"../AnimationPlayer"

@export_group("Timer Settings")
@export var cook_timer_time: float = 1
@onready var timer_ui: TextureProgressBar = $"../SubViewport/TextureProgressBar"
@onready var cook_timer: Timer = $CookTimer

##ingredient settings
var saved_prep_group: BaseFood.PrepGroup
var current_ingredient: PackedScene
var collected_ingredients : Array[PackedScene]
var current_ingredient_tags: Array
var collected_ingredient_tags : Array[Array]

func _ready() -> void:
	if (timer_ui == null):
		push_error("Timer UI cannot be found!")
	timer_ui.visible = false
	is_cooking = false
	%Prompts.hide()

func _process(_delta: float) -> void:
	#timer animation
	timer_ui.value = 100 / cook_timer.time_left
	
	#start cooking
	if (Input.is_action_just_pressed("cook") && is_in_range && collected_ingredient_tags.size() >= 1):
		is_cooking = true
		#find_recipe()
		start_cook_timer()
		
	if (Input.is_action_just_pressed("Reset") && is_in_range):
		return_ingredients()

##Takes ingredient thrown at it. Won't start until player presses "cook" (f)
func _on_body_entered(body: Node3D) -> void:
	if (body.has_method("im_food") && !is_full && !is_cooking): #checks if body is an ingredient. This check should be made better later.
		print("yum, I found a food!: ", body)
		if (body.cook_group != 0):
			print("can't take, it's already been cooked!")
		else:
			if station_ui.filled >= station_ui.capacity:
				return
			else:
				station_ui._update_visual(body.icon)
			
			#set ingredient to cooked
			body.cook_group = cook_group_application_type
			
			#take ingredient data
			saved_prep_group = body.prep_group
			current_ingredient = load(body.scene_file_path)
			current_ingredient_tags = [body.food_group, body.prep_group, body.cook_group]
			
			#add ingredient data to main array
			collected_ingredients.append(current_ingredient)
			collected_ingredient_tags.append(current_ingredient_tags)
			
			#delete obj
			body.queue_free()
			
			##debugging lines
			#print("ingredient: ", current_ingredient)
			#print("collected ingredient tags: ", current_ingredient_tags)
			#print("collected ingredients:", collected_ingredient_tags)
			
			#is_full = true

func start_cook_timer():
	#set timer time
	timer_ui.visible = true
	station_ui.visible = false
	cook_timer.wait_time = cook_timer_time
	
	##animation start 
	
	cook_timer.start()

func _on_cook_timer_timeout() -> void:
	print("prep timeout!")
	timer_ui.visible = false
	station_ui.visible = true
	
	##animation end
	animation.play("open_close")
	
	find_recipe()

func find_recipe():
	print("cooking...")
	var chosen_recipe = null #recipe is dubious food by default
	var recipe_spawn = null
	var recipe_tags: Array
	
	#sort ingredients by index 
	collected_ingredient_tags.sort()
	
	# All Recipes in appliance array
	for recipe in recipes: 
		#get recipe tags into array
		for ing in recipe.food_group_array:
			var ing_array = [ing.food_group, ing.prep_group, ing.cook_group]
			recipe_tags.append(ing_array)
		#sort recipe tags by index
		recipe_tags.sort()
		
		##debugging lines
		#print(str("INGREDIENTS FOUND: ", collected_ingredient_tags))
		#print(str("RECIPE NAME: ", recipe.recipe_name))
		#print(str("RECIPE SPECIFICALLY IS CALLING FOR: ", recipe_tags))
		
		#check if current recipe, break loop if found
		if (collected_ingredient_tags == recipe_tags):
			print("recipe found! Recipe name: ", recipe.resource_name)
			chosen_recipe = recipe
			break
		else:
			recipe_tags.clear()
	
	# make dubious food
	if (chosen_recipe == null):
		print("dubious food")
		chosen_recipe = recipes[-1]
		
		#if (collected_ingredient_tags.size() == 1):
			#print("only one ingredient found.")
			#cook_ingredient()
			#return
		#else:
			#print("dubious food")
			#chosen_recipe = recipes[-1]
		#make_soup() #<- or make dubious food
		#return
	
	#spawn selected recipe into scene
	var current_scene = get_tree().current_scene
	recipe_spawn = chosen_recipe.product.instantiate()
	current_scene.add_child(recipe_spawn)
	print("spawning: ", recipe_spawn)
	recipe_spawn.position = spawn_position.global_position
	
	#clear data 
	collected_ingredients.clear()
	collected_ingredient_tags.clear()
	station_ui._reset_visual()
	chosen_recipe = null
	is_cooking = false
	return

##cooks one ingredient even if it doesnt make a valid meal. currently isnt being used.
func cook_ingredient():
	var ingredient_spawn: Node
	#spawn back cooked ingredient
	var current_scene = get_tree().current_scene
	ingredient_spawn = current_ingredient.instantiate()
	ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	current_scene.add_child(ingredient_spawn)
	print("spawning: ", ingredient_spawn)
	
	#carry over tags
	ingredient_spawn.cook_group = cook_group_application_type #Example: BaseFood.CookGroup.BAKED
	ingredient_spawn.prep_group = saved_prep_group
#
	##TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	ingredient_spawn.position = spawn_position.global_position
	#
	##clear vars for next ingredient
	collected_ingredients.clear()
	collected_ingredient_tags.clear()
	is_full = false
	is_cooking = false
	timer_ui.visible = false
	current_ingredient = null
	station_ui._reset_visual()

#func _on_cook_timer_timeout() -> void:
	#print("prep timeout!")
	#var ingredient_spawn: Node
	
	#if ()
	
	##spawn back prepped ingredient
	#var current_scene = get_tree().root
	#ingredient_spawn = ingredient.instantiate()
	#ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	#current_scene.add_child(ingredient_spawn)
	#print ("spawning", ingredient_spawn)
	#
	#ingredient_spawn.cook_group = cook_group_application_type #Example: BaseFood.CookGroup.BAKED
	##print("cook time up! is prepped: ", ingredient_spawn.prep_group)
	#ingredient_spawn.prep_group = saved_prep_group
#
	##TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	#ingredient_spawn.position = Vector3(0, 2, 0.1)
	#
	##clear vars for next ingredient
	#timer_ui.visible = false
	#is_full = false
	#ingredient = null

func return_ingredients():
	#spawn back prepped ingredient
	for ingredient in collected_ingredients:
		var ingredient_spawn: Node
		#spawn back prepped ingredient
		var current_scene = get_tree().root
		ingredient_spawn = ingredient.instantiate()
		ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
		ingredient_spawn.prep_group = saved_prep_group #add tags
		
		current_scene.add_child(ingredient_spawn)
		print ("spawning: ", ingredient_spawn)
		
		#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
		ingredient_spawn.position = spawn_position.global_position
		
		current_ingredient = null
	
	#clear data
	collected_ingredients.clear()
	collected_ingredient_tags.clear()
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
