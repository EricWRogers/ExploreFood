extends Area3D

##Preps ingredients for plating meal
##
##Right now the prepper just takes the food at sets the bool "prepped" to true, allowing the plate to accept it
##Down the line, the hope is to destroy the unprepped ingredient and spawn a prepped one 
##(ex: meat nose to meat ball, dough baby to fried dough, etc)

@onready var cook_timer: Timer = $CookTimer
@export var cook_timer_time: float = 1
@onready var timer_ui: TextureProgressBar = $"../SubViewport/TextureProgressBar"
@export var spawn_position: Vector3 = Vector3(0, 0, 0)
var ingredient: PackedScene
var is_full: bool = false

func _ready() -> void:
	if (timer_ui == null):
		push_error("Timer UI cannot be found!")
	timer_ui.visible = false

func _process(delta: float) -> void:
	timer_ui.value = 100 / cook_timer.time_left
	#print("cook timer time left: ", cook_timer.time_left)
	#print("timer ui", timer_ui.value)

func _on_body_entered(body: Node3D) -> void:
	if (body.has_method("im_food") && !is_full): #checks if body is an ingredient. This check should be made better later.
		print("yum, I found a food! is prepped: ", body.is_prepped)
		ingredient = load(body.scene_file_path)
		body.queue_free()
		print(ingredient)
		is_full = true
		
		start_cook_timer()

func start_cook_timer():
	#set timer time
	timer_ui.visible = true
	
	cook_timer.wait_time = cook_timer_time
	cook_timer.start()

func _on_cook_timer_timeout() -> void:
	var ingredient_spawn
	
	#spawn prepped ingredient
	var current_scene = get_tree().root
	ingredient_spawn = ingredient.instantiate()
	ingredient_spawn.rarity_level = 1
	current_scene.add_child(ingredient_spawn)
	ingredient_spawn.is_prepped = true
	print("cook time up! is prepped: ", ingredient_spawn.is_prepped)
	
	#hide timer
	$"../SubViewport/TextureProgressBar".visible = false
	
	#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	ingredient_spawn.position = Vector3(-5.6, 2, 0.1)
	print ("spawning", ingredient_spawn)
	#clear vars for next ingredient
	is_full = false
	ingredient = null
