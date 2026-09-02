extends Node
class_name food

@export var ing_stats: ingredient_resource
@onready var food_mesh: MeshInstance3D = $StaticBody3D/MeshInstance3D

func _ready():
	food_mesh = MeshInstance3D.new()
	food_mesh.mesh = ArrayMesh.new()
	food_mesh.mesh = ing_stats.model
#	food_mesh.Material = ing_stats.mat
