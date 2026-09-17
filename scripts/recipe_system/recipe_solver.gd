extends Node

#all valid recipes in the game have to be put in this array. 
#TODO: come up with a better solution than manually placing recipes in array. Maybe it grabs from a file?
@export var recipes : Array[Resource] 
var ingredient_types : Array
var isCooking = false

#TODO: Make the plate only accept the ingredient when player hits "interact"
func _ready() -> void:
	pass
	#if Input.is_action_just_pressed("interact"):
		#plate()

#if ingredient hits plate, grab array of ingredient types and then delete the ingredient
#TODO: Make the plate only accept ingredient marked "Prepped"
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("RollSpawn"):
		ingredient_types.append(body.category)
		body.queue_free()
		print(ingredient_types)

func find_recipe():
	var chosen_recipe = recipes[-1] #recipe is dubious food by default
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
	
	#spawn selected recipe into scene
	var current_scene = LevelManager.current_level
	recipe_spawn = chosen_recipe.product.instantiate()
	current_scene.add_child(recipe_spawn)
	#TODO: Change spawn point. Hard coding point is.. fine.. but should probably spawn on top of a specific obj or something instead?
	recipe_spawn.position = Vector3(-1,1.7,-6) 
	
	#empty list for next batch
	ingredient_types.clear()
	chosen_recipe = null
	return
