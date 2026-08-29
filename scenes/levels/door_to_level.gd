extends Area3D

@export var inital_scene: StringName = &"uid://c6e1k24uvewn0"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body):
	print("Entering")
	if body.is_in_group("Player"):
		SceneLoader.load_scene(inital_scene)
		
