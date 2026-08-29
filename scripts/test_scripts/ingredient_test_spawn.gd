extends Node

@onready var spawn_point: Marker3D = $spawn_point
var spawn_apple = preload("res://scenes/prefabs/Ingredients/food.tscn")

func _ready() -> void:
	var instance = spawn_apple.instantiate()
	add_child(instance)
	instance.position = spawn_point.position
