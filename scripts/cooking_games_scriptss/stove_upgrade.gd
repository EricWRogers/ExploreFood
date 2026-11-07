extends Node3D

const STOVE_OVEN = preload("uid://1t6b8uqug4od")
var player_close = false
var bought = false
@export var cost : int = 10


func _ready() -> void:
	$Node3D/Label3D.text = "New Stove \n Cost: $" + str(cost)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_close and Manager.money >= cost and Input.is_action_just_pressed("Interact") and !bought:
		var stove = STOVE_OVEN.instantiate()
		add_child(stove)
		stove.global_position = $StoveSpawn.global_position
		stove.global_rotation_degrees = Vector3(0.0, -90, 0.0)
		stove.scale = Vector3(1.75, 1.75, 1.75)
		bought = true
	if bought:
		$Node3D.hide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !bought:
		$Node3D.show()
		player_close = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$Node3D.hide()
		player_close = false
