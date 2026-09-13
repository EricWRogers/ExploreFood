extends StaticBody3D

@export var lvl_manager: Node
@export var recipes : Array[Resource]
@onready var cook_pointer_UItip: Node3D = $Node3D

var food_types : Array
var cooking = false
var sandwich_mode = false
var current_value = 0

#list of all recipes
#list of current foods in array

func _ready() -> void:
	if get_tree().current_scene.SandwichMode:
		sandwich_mode = true
	lvl_manager = $"../.."

func _process(_delta: float) -> void:
	if sandwich_mode:
		return
	if Input.is_action_just_pressed("cook"):
		start_cooking()

#sort through all the foods in current food array
#for each food in food array, whittle down list of recipes
#when only one recipe is left, instansiate product from that recipe
#if no recipe is found, make disgusting food

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("RollSpawn"):
		cook_pointer_UItip.show()
		
		if sandwich_mode:
			#food_types.append(body.processed_ingredient)
			Manager.food_in_pot.append(body.scene_file_path)
			current_value += body.value
		else:
			food_types.append(body.category)
		update_held_item(body.id)
		body.queue_free()
		print(food_types)
	if body.has_method("start_hunger"):
		$Funny.show()
		
	#if item in area is an ingredient
	
func start_cooking():
	cook_pointer_UItip.hide()
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
			print("you made dubious")
			chosen_recipe = recipes[-1]
	
	var current_scene = lvl_manager.current_level
	var recipe_spawn = null
	recipe_spawn = chosen_recipe.product.instantiate()
	current_scene.add_child(recipe_spawn)
	recipe_spawn.position = Vector3(-1,1.7,-6)
	
	#empty list for next batch
	food_types.clear()
	current_recipe = null
	chosen_recipe = null
	return
	
func construct_bagel():
	pass
	
	#var current_scene = lvl_manager.current_level
	#bagel_bottom.price = current_value
	#current_scene.add_child(bagel_bottom)
	#for item in food_types:
		#bagel_bottom.add_spread(item)
	#bagel_bottom.add_top()
	#food_types.clear()
	#bagel_bottom.global_position = self.global_position
	#bagel_bottom.global_position.y += 1.0
	#current_value = 0
	
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
	if sandwich_mode:
		construct_bagel()
	else:
		find_recipe()
	reset_held()
	$Cooking.play("RESET")
	$StaticBody3D.set_collision_layer_value(1, false)
	$StaticBody3D/PotLid.hide()
	$AnimationPlayer.play("RESET")
