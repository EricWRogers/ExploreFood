extends Node

##Applies cooking tag to ingredients placed inside
##if ingredients make a valid meal, it will output that meal instead
##

@export_group("Appliance Settings")
@export var cook_group_application_type: BaseFood.CookGroup
@export var spawn_position: Vector3 = Vector3(0, 0, 0)
var is_full: bool = false
var is_cooking: bool = false

@export_group("Timer Settings")
@export var cook_timer_time: float = 1
@onready var timer_ui: TextureProgressBar = $"../SubViewport/TextureProgressBar"
@onready var cook_timer: Timer = $CookTimer

##ingredient settings
@export var recipes : Array[Resource] 
var collected_ingredients_prep_groups: Array[BaseFood.PrepGroup]
var ingredient: PackedScene
var saved_prep_group: BaseFood.PrepGroup
var collected_ingredients: Array

var ing_food_tags: Array
var collected_ingredient_tags : Array[Array]

func _ready() -> void:
	if (timer_ui == null):
		push_error("Timer UI cannot be found!")
	timer_ui.visible = false

func _process(_delta: float) -> void:
	#timer animation
	timer_ui.value = 100 / cook_timer.time_left
	#print("cook timer time left: ", cook_timer.time_left)
	#print("timer ui", timer_ui.value)
	
	#start cooking
	if (Input.is_action_just_pressed("cook") && collected_ingredients.size() >= 1):
		print("cooking...")
		is_cooking = true
		find_recipe()
		start_cook_timer()

##Takes ingredient thrown at it. Won't start until player presses "cook" (f)
func _on_body_entered(body: Node3D) -> void:
	if (body.has_method("im_food") && !is_full && !is_cooking): #checks if body is an ingredient. This check should be made better later.
		#print("yum, I found a food! is prepped: ", body.prep_group)
		if (body.cook_group != 0):
			print("can't take, it's alreday been cooked!")
		else:
			#set ingredient to cooked
			body.cook_group = cook_group_application_type
			
			#take ingredient data
			print("FOOD TAG ARRAYS: ", body.food_tags)
			saved_prep_group = body.prep_group 
			ingredient = load(body.scene_file_path)
			ing_food_tags = [body.food_group, body.prep_group, body.cook_group]
			
			#add ingredient data to arrays
			collected_ingredients.append(body.food_group)
			collected_ingredients_prep_groups.append(saved_prep_group)
			collected_ingredient_tags.append(ing_food_tags)
			
			#delete obj
			body.queue_free()
			print("ingredient: ", ingredient)
			print("ingredient tags: ", ing_food_tags)
			print("ingredient list: ", collected_ingredients)
			print("collected tags:", collected_ingredient_tags)
			#is_full = true
			#start_cook_timer()

##quick and dirty test for finding recipes. Will replace giant if statements with resources
func find_recipe():
	var chosen_recipe = null #recipe is dubious food by default
	var recipe_spawn = null
	var recipe_tags: Array
	
	#sort ingredients by index 
	#collected_ingredients.sort()
	#print(str("sorted collected ingredients: ", collected_ingredients))
	
	#if tags are these:
	for recipe in recipes: # All Recipes in Array
		#sort each recipe by index
		#recipe.ingredients.sort()
		for ing in recipe.food_group_array:
			print(str("ingredient tags: ", ing.food_group, ing.prep_group, ing.cook_group))
			var ing_array = [ing.food_group, ing.prep_group, ing.cook_group]
			recipe_tags.append(ing_array)
	
		print(str("INGREDIENTS FOUND: ", collected_ingredient_tags))
		print(str("RECIPE NAME: ", recipe.recipe_name))
		print(str("RECIPE SPECIFICALLY IS CALLING FOR: ", recipe_tags))
		
		#check if current recipe, break loop if found
		if (collected_ingredient_tags == recipe_tags):
			print("recipe found! YAYAYAYAYAYAYAY!!!!!!!!!!!!!!!!")
			chosen_recipe = recipe
			break
		
	# make dubious food
	#if chosen_recipe == null:
		#make_soup() #<- or make dubious food
	#	return
	
	#spawn selected recipe into scene
	#var current_scene = get_tree().root
	#recipe_spawn = chosen_recipe.product.instantiate()
	#current_scene.add_child(recipe_spawn)
	
	#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	#recipe_spawn.position = Vector3(-1.4, 1, -15.5) 
	
	#empty list for next batch
	collected_ingredient_tags.clear()
	chosen_recipe = null
	return
	#print name of meal
	
	#spawn meal
	#recipe_spawn = chosen_recipe.product.instantiate()

func start_cook_timer():
	#set timer time
	timer_ui.visible = true
	cook_timer.wait_time = cook_timer_time
	cook_timer.start()

func _on_cook_timer_timeout() -> void:
	print("prep timeout!")
	#var ingredient_spawn: Node
	
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
	timer_ui.visible = false
	#is_full = false
	#ingredient = null
