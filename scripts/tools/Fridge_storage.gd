extends StaticBody3D

@export var ing : BaseFood :
	set(value):
		ing = value
		ing.node = self
		$Sprite2d.texture = value.icon #change to account for 3d
				
var current_ingredient: PackedScene  
var stored_ingredents: Array[PackedScene]

@export var fridgeLimit = 6

#setter varuble to controle the visibillity of the lable
var enabled : bool = false:
	set(value):
		enabled = value 
		
func _ready():
	enabled = false
	#name = ing.title #update name with item title

func _input(event):
	#check if enabled and if key pressed
	if (event is InputEventKey && 
		event.is_pressed() && 
		event.keycode == KEY_E &&
		enabled):
			#print(name + "Activated.") #testing 
			if (Manager.holding == true): #if holding put itme in fridge
				current_ingredient = Manager.currently_held_food#get the ingredent player is holding
				print(current_ingredient)
				current_ingredient.queue_free() #delete body
				insert()
			else: #if nothing in hand take item out of stack
				remove()
			

func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		enabled = true
	if(body.has_method("im_food") && enabled):
		current_ingredient = load(body.scene_file_path)
		body.queue_free()
		insert()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		enabled = false
#	if ing:  #exiting body will deactivate item
#		ing.de_activate()

		
#only saves raw ingredents, not cooked or preped
func insert():
	#add to array, set current ingendent == body/held food, delete body
	#current_ingredient = load(body.scene_file_path)
	#body.queue_free()
	
	if (stored_ingredents.size() >= fridgeLimit):
		return
	else:
		stored_ingredents.append(current_ingredient) 
		#not removeing ingredent from player hand, not puting anything into stored_ingredents
	print(stored_ingredents) #testing
	
		
#grab index from array and spit out ingredent
func remove():
	print("removing...")
	print("stored ingredients: ", stored_ingredents)
	print("stored ingredienta[-1]: ", stored_ingredents[-1])
	if (stored_ingredents[-1] == null || stored_ingredents.is_empty()): 
			return
	else:
		var ingredient_spawn: PackedScene
		ingredient_spawn = stored_ingredents[-1]
		var current_scene = get_tree().current_scene
		var temp = ingredient_spawn.instantiate() 
		temp.rarity_level = 1 #makes sure that the food is guarenteed to spawn
		current_scene.add_child(temp)
		stored_ingredents.remove_at(-1) #remove ingredent from array
	
	#ingredent_spawn = stored_ingredent[0]
	#var current_scene = get_tree().current_scene
	#ingredient_spawn = current_ingredient.instantiate() 
	#ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	#current_scene.add_child(ingredient_spawn)
	#print("spawning: ", ingredient_spawn)
