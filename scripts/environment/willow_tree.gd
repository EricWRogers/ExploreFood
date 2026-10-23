extends Node3D

@onready var tear_baby: BaseFood = $TearBabyScaler/TearBaby
@onready var tear_baby_2: BaseFood = $TearBaby2Scaler/TearBaby2
@onready var willow_cry_l: Node3D = $WillowCryL
@onready var willow_cry_r: Node3D = $WillowCryR

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_cried: bool = false
var player_inside = false


func _process(delta: float) -> void:
	if(player_inside && Manager.holding):
		if !has_cried:
				animation_player.play("willow_tree_cry")
				has_cried = true
		willow_cry_l.start_cry()
		willow_cry_r.start_cry()
	else:
		willow_cry_l.stop_cry()
		willow_cry_r.stop_cry()
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		player_inside = true



func _on_area_3d_body_exited(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		player_inside = false
