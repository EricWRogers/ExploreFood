extends Node3D

var recipe_collectables: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	recipe_collectables = get_tree().get_nodes_in_group("Recipe_Collectable")
	print("recipes in this scene: ", recipe_collectables)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
