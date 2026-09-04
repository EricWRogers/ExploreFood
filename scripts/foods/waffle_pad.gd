extends BaseFood
class_name WaffleFood

const BUTTER_FROG = preload("uid://cuudja02uqggj")

var has_butter := false

func _ready():
	super()
	

func on_looked_at():
	super()
	
	print("Do something extra")
	$Node3D/Label3D.show()
	
func get_took():
	if not has_node("ButterFrog"):
		super()
	else:
		var new_butter = BUTTER_FROG.instantiate()
		new_butter.rarity_level = 1
		var current_scene = get_tree().current_scene
		current_scene.add_child(new_butter)
		new_butter.global_position = self.global_position
		new_butter.freeze = false
		super()
	
	
func get_rolled():
	super()
