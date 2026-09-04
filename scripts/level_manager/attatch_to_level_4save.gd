class_name Level extends Node3D

const LEVEL_SAVE_FOLDER: String = "user://level_saves"
#user will put the savefiles on the computer ^
#project setting -> open user data folder

enum LevelIDs {
	NONE = 0,
	#add maps as needed with ID number
	WORLD_1 = 1,
	WORLD_2 = 2,
	WORLD_3 = 3,
}

@export var level_id: LevelIDs
#select the level and set level ID (right>>)

static var current_level: Level
#Level.current_level.save_level_data() #how to save current game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level = self
	DirAccess.make_dir_absolute(LEVEL_SAVE_FOLDER)
	
	load_level_data()
	save_level_data()

func get_level_save_file_path() -> String:
	return LEVEL_SAVE_FOLDER + str("level_save_", level_id) + ".tres"
		#keep as .tres for debugging but change to .res full game ^

func save_level_data() -> void:
	var new_save = MapSaveData.new()
	
	for saver: SaverNode in get_tree().get_nodes_in_group(SaverNode.SAVER_NODE_GROUP):
		var node_path = get_path_to(saver)
		new_save.data[node_path] = saver.get_save_dict()
	
	ResourceSaver.save(new_save, get_level_save_file_path())
	print("Saved level data to", get_level_save_file_path()) #for debugging
	
func load_level_data() -> void:
	if not FileAccess.file_exists(get_level_save_file_path()):
		return
	
	print("loading level data from", get_level_save_file_path())
	var loaded_save = ResourceLoader.load(get_level_save_file_path()) as MapSaveData
	
	for path in loaded_save.data: #load the data back onto object
		var saver_node = get_node_or_null(path)
		if saver_node:
			saver_node.apply_save_dict(loaded_save.data[path])
