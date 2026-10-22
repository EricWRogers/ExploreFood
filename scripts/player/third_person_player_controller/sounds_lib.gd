extends Node3D

@onready var sounds = {
	"Wood": [
		preload("res://assets/sounds/SFX/90_Player_Movement_SFX/10_Step_wood_01.wav"),
		preload("res://assets/sounds/SFX/90_Player_Movement_SFX/11_Step_wood_02.wav"),
		preload("res://assets/sounds/SFX/90_Player_Movement_SFX/12_Step_wood_03.wav")
	],
	"Grass": [
		preload("res://assets/sounds/SFX/90_Player_Movement_SFX/01_Step_grass_01.wav"),
		preload("res://assets/sounds/SFX/90_Player_Movement_SFX/02_Step_grass_02.wav"),
		preload("res://assets/sounds/SFX/90_Player_Movement_SFX/03_Step_grass_03.wav")
	]
}

func get_surface_play_footsteps(ray: RayCast3D) -> void:
	if not ray.is_colliding(): return
	var collider = ray.get_collider()
	var parent = collider.get_parent()
	var surface = "Wood"
	if parent.has_meta("Surface"):
		surface = parent.get_meta("Surface")
	var surface_sounds = sounds.get(surface, sounds["Wood"])
	if surface_sounds.is_empty(): return
	$"../AudioStreamPlayer3D"._play_footstep(surface_sounds.pick_random())
