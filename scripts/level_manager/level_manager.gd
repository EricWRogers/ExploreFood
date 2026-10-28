class_name LevelManager extends Node

###
#
##BUG: only allows one scene per parent at a time. Need to allow multiple scenes instead of just one
##BUG: REMOVE DOESNT WORK AAAAAAAAHHHH
#
###

@onready var scene_parent_3D: Node3D = $SceneParent3D
@onready var scene_parent_2D: Node2D = $SceneParent2D
@onready var scene_parent_control: Control = $SceneParentControl

#var current_3D_scene: Node
#var current_2D_scene: Node
#var current_GUI_scene: Node

var scene_cache: Dictionary[String, Node] = {} #store loaded scenes by path
enum change_mode {HIDE, REMOVE, DELETE, KEEP}
#enum node_type {NODE3D, NODE2D, NODECONTROL}

#called when script is instantiated. 
func _init() -> void:
	Manager.level_manager = self
	print("level manager init")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	#print("3D scene parent: ", scene_parent_3D.name)
	#print("2D scene parent: ", scene_parent_2D.name)
	#print("Control scene parent: ", scene_parent_control.name)
	#
	#if(scene_parent_3D.get_child_count() > 0):
		#current_3D_scene = scene_parent_3D.get_child(0)
		#print("default 3D scene: ", current_3D_scene)
	##
	#if(scene_parent_2D.get_child_count() > 0):
		#current_2D_scene = current_2D_scene.get_child(0)
		#print("default 2D scene: ", current_2D_scene)
	##
	#if(scene_parent_control.get_child_count() > 0):
		#current_GUI_scene = current_GUI_scene.get_child(0)
		#print("default GUI scene: ", current_GUI_scene)


func change_scene(new_scene: String, old_scene: Node, mode: change_mode = change_mode.DELETE) -> void:
	if (old_scene != null):
		match mode:
			change_mode.HIDE:
				#print("HIDE")
				hide_scene(old_scene)
				
			change_mode.REMOVE:
				#print("REMOVE")
				delete_scene(old_scene)
				
			change_mode.DELETE:
				#print("DELETE")
				delete_scene(old_scene)
				
			change_mode.KEEP:
				#print("KEEP")
				pass
	
	#load new scene
	load_scene(new_scene)

func hide_scene(_old_scene: Node):
	_old_scene.visable = false #keeps in memory and running

func remove_scene(_old_scene: Node):
	var scene_parent = _old_scene.get_parent()
	scene_parent.remove_child(_old_scene) #keeps in memory, does not run
	#scene_parent_3D.remove_child(current_3D_scene)  

func delete_scene(_old_scene: Node):
	print("DELETE")
	#print("current scene NAME: ", _old_scene.name) #TestWorld
	#print("current scene FILE PATH: ", _old_scene.scene_file_path)
	if (scene_cache.has(_old_scene.scene_file_path)): 
		print("erasing SCENE: ", _old_scene) 
		scene_cache.erase(_old_scene.scene_file_path)
	
	_old_scene.queue_free() #removes node entirely

##Load a new scene
func load_scene(_new_scene: String):
	print("loading scene...")
	print("pre-load cache:", scene_cache)
	var new_node: Node
	
	if scene_cache.has(_new_scene): #check if new scene is in cache
		new_node = scene_cache[_new_scene]
		print("scene found in cache. Loading from cache...")
	else: #if new scene is not in cache, instantiate it
		print("scene was not found in cache. Instantiating...")
		new_node = load(_new_scene).instantiate()
		scene_cache[_new_scene] = new_node #scene_cache{"res://Levels/test_world.tscn": "test_world:<Node3D>"}
	
	print("new node: ", new_node)
	
	if new_node.get_parent() == null:
		if (new_node is Node3D):
			print("3D")
			scene_parent_3D.add_child(new_node)
			#current_3D_scene = new_node
		elif (new_node is Node2D):
			print("2D")
			scene_parent_2D.add_child(new_node)
			#current_2D_scene = new_node
		elif (new_node is Control):
			print("GUI")
			scene_parent_control.add_child(new_node)
			#current_GUI_scene = new_node
		else:
			printerr("Node type not recognized as one of the valid three options.")
	
	print("post-load cache:", scene_cache, "\n")
	#print("current scene: ", current_3D_scene.name)
	


## ─────────────────────────────────────────
## Old script that I am temporaily keeping so I rip the loading screen code from later
## ─────────────────────────────────────────

#@export var start_screen: Node
#@export var Hunger : bool = false
#@export var HordeMechanics : bool = false
#@export var KitchenHubToggle : bool = false
#@export var CookingMinigames : bool = false
#
#@onready var current_level
#
#var to_go
#var scene_switch_setter = false
#
#
#func _ready() -> void:
	#current_level = start_screen
	#print("current level: ", current_level)
	#start_screen.starting_game.connect(on_starting_level)
#
#func on_starting_level(_level): #emits signal from text box
	#print("diner loaded!")
	#current_level = _level
	##current_level = get_child(1)
	###when the signal "level changed" is emitted, the function "start_loading" is called
	#current_level.connect("level_changed", Callable(self, "start_loading"))
#
#func start_loading(level):
	#$LoadingScreen.play_in()
	#to_go = level
	#
#func exit_loading():
	#$LoadingScreen.play_out()
#
#func _handle_level_change(current_level_name: String):
	#var next_level
	#var next_level_name
	#
	##loads one level according to current level name. Will need to call random levels instead
	#match current_level_name: 
		#"kitchen":
			#next_level_name = "terrain_test"
		#"kitchen2":
			#next_level_name = "breakfast_dimension" #change this to the second level once it gets made
		#"diner":
			#next_level_name = "terrain_test"
		#"diner2":
			#next_level_name = "breakfast_dimension"
		#"terrain_test":
			#if(Manager.sandwich_mode):
				#next_level_name = "kitchen"
			#else:
				#next_level_name = "testScenes/DinerLevel_test"
		#"breakfast_dimension":
			#if(Manager.sandwich_mode):
				#next_level_name = "kitchen"
			#else:
				#next_level_name = "testScenes/DinerLevel_test"
		#_:
			#print("Error: Unidentified Level. Check str Level Name.")
			#return
	#var temp = load("res://scenes/levels/"+ next_level_name + ".tscn") #creates packed scene
	#next_level = temp.instantiate()
	#call_deferred("add_child", next_level)
	#next_level.connect("level_changed", start_loading)
	#current_level.queue_free()
	#current_level = next_level
	#scene_switch_setter = false
	#$Timer.start()
#
#
#func _on_timer_timeout() -> void:
	#if scene_switch_setter == false:
		#var current_fps = Engine.get_frames_per_second()
		#if current_fps >= 30:
			#exit_loading()
			#scene_switch_setter = true
			#$Timer.stop()
#
#
#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "LoadSceenTransition":
		#_handle_level_change(to_go)
