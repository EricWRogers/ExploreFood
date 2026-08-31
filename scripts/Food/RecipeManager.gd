extends StaticBody3D

#var cheesecake : Array #array of food types
@export var recipes : Array[Resource]
var food_types : Array

#list of all recipes
#list of current foods in array

func _ready() -> void:
	pass

func _process(delta: float) -> void:
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
	var chosen
	for item in recipes: 
		for i_types in food_types: 
			if i_types in item.ingredients:
				current_recipe = item
				print(current_recipe)
			else:
				current_recipe = null
			continue
		if current_recipe:
			print(current_recipe)
			print("make chicken")
			chosen = current_recipe
			return chosen
		else:
			print("dubious")
			chosen = "Dubious"
			return chosen
		
	return chosen
