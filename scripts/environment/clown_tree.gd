extends Node3D
@onready var mystery_meat: BaseIngredient = $MysteryMeat
@onready var mystery_meat_2: BaseIngredient = $MysteryMeat2
@onready var mystery_meat_3: BaseIngredient = $MysteryMeat3

var has_checked_noses: bool = false

var noses = []
var og_nose_scale
var player_speed = 1.0
var speed_limit :float
var player_close : bool = false;
var target_scale

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	speed_limit = player.sprint_speed - 3.0
	noses.append(mystery_meat)
	noses.append(mystery_meat_2)
	noses.append(mystery_meat_3)
	print(noses.size())
	og_nose_scale = $MysteryMeat.scale
	if player == null:
		push_error("NO PLAYER FOUND")
		return



func _physics_process(delta: float) -> void:

	if player != null:
		player_speed = player.velocity.length()
	else:
		player = get_tree().get_first_node_in_group("Player")

	
	if player_close and player_speed > speed_limit:
		target_scale = 3.0
	else:
		target_scale = 1.0
	for nose in noses:
		if nose != null:
			nose.scale = nose.scale.lerp(og_nose_scale * target_scale, delta / 2.0)
			if nose.scale.length() >= (og_nose_scale * 3.0).length() * 0.85:
				explode(nose)

func explode(nose: RigidBody3D) -> void:

	var explosion = nose.get_node("Explosion")
	explosion.reparent(get_tree().current_scene)
	explosion.explode()

	noses.erase(nose)
	nose.queue_free()




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player is close")
		player_close = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_close = false
