extends BaseFood
class_name Butter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
func get_rolled():
	if get_parent().get("id") != null:
		if get_parent().id == 2:
			var current_scene = get_tree().current_scene
			var world_transform = global_transform

			get_parent().remove_child(self)
			current_scene.add_child(self)

			global_transform = world_transform
	else:
		super()
