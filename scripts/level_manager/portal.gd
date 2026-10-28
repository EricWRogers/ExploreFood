extends Area3D

@export_group("Level Change")
##detects the current level that the portal is in
var current_level: Node 
##Name of the level that will be loaded in. 
##Make sure that new_level includes the full file path WITHOUT quotation marks.
##example: res://levels/test_world.tscn
@export var new_level_path: String
##What you will do to the old level
@export var change_mode = Manager.level_manager.change_mode.DELETE

@export_group("Activation")
@export var in_kitchen = true
@export var active : bool = false

@export_group("Apperance")
@export var image_of_world : Texture
@export var light_color: Color
@onready var mat = $Portalmesh.get_surface_override_material(0)

func _ready() -> void:
	current_level = self.get_owner()
	#print("new level path: ", new_level_path)
	#print("portal current level: ", current_level)
	
	if !in_kitchen:
		unlock()
	
	if !active:
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(1, false)
		$Portalmesh.hide()
		$OmniLight3D.hide()
	$OmniLight3D.light_color = light_color
	mat.set_shader_parameter("albedo_texture", image_of_world)

func unlock():
	$AnimationPlayer.play("unlock")

func _on_body_entered(body: Node3D) -> void:
	# player goes through portal - load new level #
	if (body.is_in_group("Player")):
		# check new level string validity #
		if (new_level_path == "" || new_level_path == " " || new_level_path == null):
			printerr("Portal %s new_level_path is null. Make sure you fill write the level path in the inspector!" % self.name)
			return
		elif(!new_level_path.begins_with("res://") || !new_level_path.ends_with(".tscn")):
			printerr("Portal %s new_level_path is unrecognized. Did you write in the node's name instead of its file path?" % self.name)
			return
		
		# debug lines #
		print("change level! new level: ", new_level_path)
		#print("portal current level: ", current_level)
		
		# change scene #
		Manager.level_manager.call_deferred("change_scene", new_level_path, current_level, change_mode) #GlobalLevel.level_manager.change_mode.DELETE
	
	# food goes through portal - add to collected food array #
	if (!in_kitchen && body.has_method("im_food")):
		Manager.collected_food.append(body.scene_file_path)
		body.queue_free()
