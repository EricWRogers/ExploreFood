extends StaticBody3D

@export var lvl_manager: Node
@export var recipes : Array[Resource]
var food_types : Array
var cooking = false

#list of all recipes
#list of current foods in array

func _ready() -> void:
	lvl_manager = $"../.."

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cook"):
		start_cooking()

#sort through all the foods in current food array
#for each food in food array, whittle down list of recipes
#when only one recipe is left, instansiate product from that recipe
#if no recipe is found, make disgusting food

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("RollSpawn"):
		food_types.append(body.category)
		update_held_item(body.id)
		body.queue_free()
		print(food_types)
		
	#if item in area is an ingredient
	
func start_cooking():
	if cooking == true:
		return
	if food_types.is_empty():
		return
	cooking = true
	$StaticBody3D.set_collision_layer_value(1, true)
	$StaticBody3D/PotLid.show()
	$Timer.start()
	$Cooking.play("Cooking")
	pass

func find_recipe():
	var current_recipe
	var chosen_recipe
	for recipe in recipes: # All Recipes in Array
		food_types.sort()
		recipe.ingredients.sort()
		print(str("FOOD TYPES: ", food_types))
		print(str("RECIPE CALLS FOR: ", recipe.ingredients))
		if food_types == recipe.ingredients:
			print("hello you won")
			chosen_recipe = recipe
			break
		else:
			print("you made shit")
			chosen_recipe = recipes[-1]
		
		#if current_recipe:
			#print("make meal")
			#chosen_recipe = current_recipe
		#else:
			#print("dubious")
			#chosen_recipe = recipes[0] #dubious food
	
	print("current recipe: ", current_recipe)
	
	#spawn chosen food
	#print(chosen_recipe.product) 
	
	var current_scene = lvl_manager.current_level
	var recipe_spawn = null
	recipe_spawn = chosen_recipe.product.instantiate()
	current_scene.add_child(recipe_spawn)
	recipe_spawn.position = Vector3(-4.1,1.7,0)
	
	#empty list for next batch
	food_types.clear()
	current_recipe = null
	chosen_recipe = null
	return
	
func update_held_item(id):
	match id:
		0:
			reset_held()
		1:
			$FoodRot/Terry.show()
		2:
			$FoodRot/Waffle.show()
		3:
			$FoodRot/Frogbutt.show()
		4:
			pass
		5:
			$FoodRot/Bebeh.show()
		6:
			pass
		7:
			$FoodRot/DoughBebeh.show()
		8:
			$FoodRot/MeatBall.show()

func reset_held():
	$FoodRot/Frogbutt.hide()
	$FoodRot/Terry.hide()
	$FoodRot/Waffle.hide()
	$FoodRot/Bebeh.hide()
	$FoodRot/DoughBebeh.hide()
	$FoodRot/MeatBall.hide()


func _on_timer_timeout() -> void:
	cooking = false
	find_recipe()
	reset_held()
	$Cooking.play("RESET")
	$StaticBody3D.set_collision_layer_value(1, false)
	$StaticBody3D/PotLid.hide()
	$AnimationPlayer.play("RESET")
