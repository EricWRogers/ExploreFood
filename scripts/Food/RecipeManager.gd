extends StaticBody3D

@export var lvl_manager: Node
@export var recipes : Array[Resource]
var food_types : Array

#list of all recipes
#list of current foods in array

func _ready() -> void:
	lvl_manager = $"../.."

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("create_icon"):
		find_recipe()

#sort through all the foods in current food array
#for each food in food array, whittle down list of recipes
#when only one recipe is left, instansiate product from that recipe
#if no recipe is found, make disgusting food

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("RollSpawn"):
		food_types.append(body.category)
		body.queue_free()
		print(food_types)
		
	#if item in area is an ingredient

func find_recipe():
	var current_recipe
	var chosen_recipe
	
	for item in recipes: 
		for i_types in food_types: 
			if i_types in item.ingredients:
				current_recipe = item
				#print(current_recipe)
			else:
				current_recipe = null
			continue
		if current_recipe:
			print("make meal")
			chosen_recipe = current_recipe
		else:
			print("dubious")
			chosen_recipe = recipes[0] #dubious food
	
	print("current recipe: ", current_recipe)
	
	#spawn chosen food
	print(chosen_recipe.product) 
	var current_scene = lvl_manager.current_level
	var recipe_spawn = chosen_recipe.product.instantiate()
	current_scene.add_child(recipe_spawn)
	recipe_spawn.position = Vector3(-4.1,1.7,0)
	
	#empty list for next batch
	food_types = []
	return
