extends StaticBody3D

#var cheesecake : Array #array of food types
var recipes : Array
var food_types : Array

#list of all recipes
#list of current foods in array

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

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
	
	#var ing_to_look = item #get item
	#var ing_ftype = ing_to_look.foodType
	
	#for item in items_in_pot:
		
		#default result is dubious food
		
		#for loop i in recipe list 
			#loop through each key in recipe
				#if ing_to_look = food type
					#add to list of potential recipes
					#break
				#else
					#go to next
		#match ing_to_look:
			#pass
