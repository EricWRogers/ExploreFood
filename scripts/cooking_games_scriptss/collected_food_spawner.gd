extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Manager.collected_food.is_empty():
		for item in Manager.collected_food:
			var fooditem = load(item).instantiate()
			fooditem._become_dropped()
			get_tree().current_scene.add_child(fooditem)
			fooditem.freeze = false
			fooditem.global_position = self.global_position
			await get_tree().create_timer(0.3).timeout
		Manager.collected_food.clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
