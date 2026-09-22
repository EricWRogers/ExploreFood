extends Node3D

@onready var portal1 : Area3D = $"../Portal"
@onready var portal2 : Area3D = $"../Portal2"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	portal1.unlock()
	
	if (Manager.is_portal_2):
		portal2.unlock()

func open_portal(portal_num: int):
	if (portal_num == 2):
		Manager.is_portal_2 = true
		portal2.unlock()
