extends Node3D

@onready var portal1 : Area3D = $"../Portal"
@onready var portal2 : Area3D = $"../Portal2"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (Manager.is_portal_1):
		portal1.unlock()
	if (Manager.is_portal_2):
		portal2.unlock()
	
	if(Manager.is_tut_over):
		$"../TutWall".visible = false
		$"../TutWall".use_collision = false

func open_portal(portal_num: int):
	if (portal_num == 1):
		Manager.is_portal_1 = true
		portal1.unlock()
	elif (portal_num == 2):
		Manager.is_portal_2 = true
		portal2.unlock()
