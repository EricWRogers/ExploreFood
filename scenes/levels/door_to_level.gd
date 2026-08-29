extends Area3D

@export var inital_scene: StringName = &"uid://c6e1k24uvewn0"

func _on_body_entered(body):
	if body.is_in_group("Player"):
		SceneLoader.load_scene(inital_scene)
		
