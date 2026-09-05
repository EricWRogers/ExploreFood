extends Node

@export var lines: Array[String] = []
@export var ui_position: Vector2
@onready var interact_ui: Node3D = $InteractUI
@onready var marker_3d: Marker3D = $Marker3D


func _ready() -> void:
	interact_ui.hide()
	ui_position = Vector2(marker_3d.position.z, marker_3d.position.y)

func _process(_delta):	
	if(Input.is_action_just_pressed("Interact")):
		if interact_ui:
			interact_ui.hide()
			DialogueManager.start_dialogue(lines)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		interact_ui.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		interact_ui.hide()
