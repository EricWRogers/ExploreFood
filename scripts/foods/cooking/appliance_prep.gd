extends Node

###Applies prep tag to ingredients placed inside
##

@export_group("Appliance Settings")
@export var prep_group_application_type: BaseFood.PrepGroup
@export var spawn_position: Vector3 = Vector3(0, 0, 0)
var is_full: bool = false

@export_group("Timer Settings")
@export var prep_timer_time: float = 1
@onready var timer_ui: TextureProgressBar = $"../SubViewport/TextureProgressBar"
@onready var prep_timer: Timer = $PrepTimer

##ingredient settings
var ingredient: PackedScene
var saved_cook_group: BaseFood.CookGroup

func _ready() -> void:
	if (timer_ui == null):
		push_error("Timer UI cannot be found!")
	timer_ui.visible = false

func _process(_delta: float) -> void:
	timer_ui.value = 100 / prep_timer.time_left
	#print("cook timer time left: ", cook_timer.time_left)
	#print("timer ui", timer_ui.value)

func _on_body_entered(body: Node3D) -> void:
	if (body.has_method("im_food") && !is_full): #checks if body is an ingredient. This check should be made better later.
		#print("yum, I found a food! is prepped: ", body.prep_group)
		
		if (body.prep_group != 0):
			print("can't take, it's alreday been prepped")
		else:
			saved_cook_group = body.cook_group
			ingredient = load(body.scene_file_path)
			body.queue_free()
			print(ingredient)
			is_full = true
			start_prep_timer()

func start_prep_timer():
	#set timer time
	timer_ui.visible = true
	
	prep_timer.wait_time = prep_timer_time
	prep_timer.start()

func _on_prep_timer_timeout() -> void:
	print("prep timeout!")
	var ingredient_spawn: Node
	
	#spawn back prepped ingredient
	var current_scene = get_tree().root
	ingredient_spawn = ingredient.instantiate()
	ingredient_spawn.rarity_level = 1 #makes sure that the food is guarenteed to spawn
	current_scene.add_child(ingredient_spawn)
	print ("spawning", ingredient_spawn)
	
	#set prep tag
	ingredient_spawn.is_prepped = true
	
	ingredient_spawn.prep_group = prep_group_application_type #Example: BaseFood.PrepGroup.CHOPPED
	#print("cook time up! is prepped: ", ingredient_spawn.prep_group)
	ingredient_spawn.cook_group = saved_cook_group

	#TODO: Change spawn point. Hard coding point is.. fine... but should probably spawn on top of a specific obj or something instead?
	ingredient_spawn.position = Vector3(0, 2, 0.1)
	
	#clear vars for next ingredient
	timer_ui.visible = false
	is_full = false
	ingredient = null
