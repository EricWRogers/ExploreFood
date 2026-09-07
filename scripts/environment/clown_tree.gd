extends Node3D

@onready var clown_mask: StaticBody3D = $ClownMask
@onready var clown_mask_2: StaticBody3D = $ClownMask2
@onready var clown_mask_3: StaticBody3D = $ClownMask3

var has_checked_noses: bool = false

var noses = []
var og_nose_scale
var too_close_distance_squared = 15.0 ** 2
var player_speed = 1.0
var speed_limit = 10.0

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player").get_child(0)

	if player == null:
		push_error("NO PLAYER FOUND")
		return



func _process(delta: float) -> void:
	if !has_checked_noses:
		noses.append(get_clown_nose(clown_mask))
		noses.append(get_clown_nose(clown_mask_2))
		noses.append(get_clown_nose(clown_mask_3))
		
		for nose in noses:
			if nose != null:
				og_nose_scale = nose.scale
			
		has_checked_noses = true

	if player != null:
		player_speed = player.velocity.length()
	else:
		player = get_tree().get_first_node_in_group("Player").get_child(0)

	var target_scale = 1.0
	

	if player_speed > speed_limit and global_position.distance_squared_to(player.global_position) < too_close_distance_squared:
		target_scale = 15.0
	for nose in noses:
		if nose != null:
			nose.scale = nose.scale.lerp(og_nose_scale * target_scale, delta)
			if nose.scale.length() >= target_scale * 0.99:
					explode(nose)


func get_clown_nose(mask: StaticBody3D) -> RigidBody3D:
	for child in mask.get_children():
		if child is RigidBody3D:
			return child
	
	return null

func explode(nose: RigidBody3D) -> void:

	var explosion = nose.get_node("Explosion")
	explosion.reparent(get_tree().current_scene)
	explosion.explode()

	noses.erase(nose)
	nose.queue_free()
