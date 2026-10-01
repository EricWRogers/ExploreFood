extends Node
##Algorithm that spawns recipes
##
##This script grabs prepped ingredients from an area entered signal, searches for a valid recipe, 
##and then spawns a meal depending on what is found

#all valid recipes in the game have to be put in this array. 
#TODO: come up with a better solution than manually placing recipes in array. Maybe it grabs from a file?
@export var recipes : Array[Resource] 
var ingredient_types : Array
var ingredient_objs = []
var isCooking = false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("cook") && ingredient_types.size() > 1):
		_find_recipe()

#if ingredient hits plate, add ingredient type to array and then delete the ingredient
#TODO: Make the plate only accept ingredient marked "Prepped"
func _on_plate_area_body_entered(body: Node3D) -> void:
	if (body.has_method("RollSpawn") && body.is_prepped): #checks if body is an ingredient. This check should be made better later.
		ingredient_types.append(body.category)
		ingredient_objs.append(body.duplicate())
		body.queue_free()
		print(ingredient_types)

func _find_recipe():
	var chosen_recipe = null #recipe is dubious food by default
	var recipe_spawn = null
	
	#sort ingredients by index 
	ingredient_types.sort() 
	
	for recipe in recipes: # All Recipes in Array
		
		#sort each recipe by index
		recipe.ingredients.sort()
		
		print(str("INGREDIENT TYPES FOUND: ", ingredient_types))
		print(str("RECIPE CALLS FOR: ", recipe.ingredients))
		
		#check if current recipe, break loop if found
		if ingredient_types == recipe.ingredients:
			print("recipe found!")
			chosen_recipe = recipe
			break
	
	if chosen_recipe == null:
		make_soup()
		return
	#spawn selected recipe into scene
	var current_scene = get_tree().root
	recipe_spawn = chosen_recipe.product.instantiate()
	current_scene.add_child(recipe_spawn)
	
	#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	recipe_spawn.position = Vector3(-1.4, 1, -15.5) 
	
	#empty list for next batch
	ingredient_types.clear()
	ingredient_objs.clear()
	chosen_recipe = null
	return

func make_soup():
	var soup_base = recipes[4].product.instantiate()
	get_tree().current_scene.add_child(soup_base)

	soup_base.position = Vector3(-1.4, 1, -15.5)

	var chunks = soup_base.get_node("Chunks")

	for i in range(min(ingredient_objs.size(), 3)):
		print("making chunks")
		var ingredient = ingredient_objs[i]
		var chunk = chunks.get_child(i)
		ingredient.scale = Vector3(0.25, 0.25, 0.25)
		ingredient.freeze = true
		ingredient.collision_layer = 2
		ingredient.collision_mask = 2

		chunk.add_child(ingredient)
		ingredient.global_position = chunk.global_position
		ingredient.global_rotation = chunk.global_rotation
	
