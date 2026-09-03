extends Node

@export var lines: Array[String] = []
@export var ui_position: Vector2
@onready var interact_ui: Node3D = $InteractUI
@onready var marker_3d: Marker3D = $Marker3D

#have script on NPC
#NPC should have e to interact label as a child
func _ready() -> void:
	interact_ui.hide()
	ui_position = Vector2(marker_3d.position.z, marker_3d.position.y)

func _unhandled_input(event):
	if event.is_action_pressed("Interact"):
		if lines.size() > 0: #change this to an area detection
			interact_ui.hide()
			DialogueManager.start_dialogue(ui_position, lines)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		interact_ui.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		interact_ui.hide()
