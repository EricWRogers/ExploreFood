extends Node3D

@onready var tear_baby: BaseFood = $TearBabyScaler/TearBaby
@onready var tear_baby_2: BaseFood = $TearBaby2Scaler/TearBaby2
@onready var willow_cry_l: Node3D = $WillowCryL
@onready var willow_cry_r: Node3D = $WillowCryR

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bodies_inside : int
var has_cried: bool = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is BaseFood and body != tear_baby and body != tear_baby_2:
		bodies_inside += 1
		if !has_cried:
			animation_player.play("willow_tree_cry")
			has_cried = true
		willow_cry_l.start_cry()
		willow_cry_r.start_cry()



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is BaseFood and body != tear_baby and body != tear_baby_2:
		willow_cry_l.stop_cry()
		willow_cry_r.stop_cry()
