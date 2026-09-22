extends Area3D

##Preps ingredients for plating meal
##
##Right now the prepper just takes the food at sets the bool "prepped" to true, allowing the plate to accept it
##Down the line, the hope is to destroy the unprepped ingredient and spawn a prepped one 
##(ex: meat nose to meat ball, dough baby to fried dough, etc)

var ingredient: PackedScene
var is_full: bool = false

@onready var cook_timer: Timer = $CookTimer
@export var cook_timer_time: float = 1

@export var spawn_position: Vector3 = Vector3(0, 0, 0)

func _on_body_entered(body: Node3D) -> void:
	if (body.has_method("im_food") && !is_full): #checks if body is an ingredient. This check should be made better later.
		print("yum, I found a food! is prepped: ", body.is_prepped)
		ingredient = load(body.scene_file_path)
		body.queue_free()
		print(ingredient)
		is_full = true
		
		#set timer time
		cook_timer.wait_time = cook_timer_time
		cook_timer.start()


func _on_cook_timer_timeout() -> void:
	var ingredient_spawn
	var current_scene = get_tree().root
	ingredient_spawn = ingredient.instantiate()
	current_scene.add_child(ingredient_spawn)
	ingredient_spawn.is_prepped = true
	print("cook time up! is prepped: ", ingredient_spawn.is_prepped)
	
	#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	ingredient_spawn.position = Vector3(0, 2, 0)
	
	#clear vars for next ingredient
	is_full = false
	ingredient = null
