extends Node

@export var dialogue_tree : Array[Dialogue] = []
@export var dialogue_tree_index : int

var lines: Array[String] = []
@export var ui_position: Vector2
@onready var interact_ui: Node3D = $InteractUI
@onready var marker_3d: Marker3D = $Marker3D
var isDialogueSelected: bool


func _ready() -> void:
	interact_ui.hide()
	isDialogueSelected = false
	ui_position = Vector2(marker_3d.position.z, marker_3d.position.y)

func _process(_delta):	
	if(Input.is_action_just_pressed("Interact") && !isDialogueSelected):
		interact_ui.hide()
		isDialogueSelected = true
		lines = dialogue_tree[0].dialogue_lines
		#print("dialogue lines from ", dialogue_tree[0], ": ", lines)
		DialogueManager.start_dialogue(lines)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		interact_ui.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		interact_ui.hide()
		isDialogueSelected = false
