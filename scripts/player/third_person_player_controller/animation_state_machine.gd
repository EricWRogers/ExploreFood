extends Node3D

var state_machine = AnimationNodeStateMachinePlayback
@onready var mult: Node3D = %mult

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = %AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _idle():
	state_machine.travel("moveset_idle")
func _walk():
	state_machine.travel("moveset_walk")
func _run():
	state_machine.travel("moveset_run")
func _jump():
	state_machine.travel("moveset_jump_anticipate")
func _fall():
	state_machine.travel("moveset_jump_apex")
func _land():
	state_machine.travel("moveset_jump_landing", 0.0)
func _cliff():
	state_machine.travel("moveset_cliff_edge")
func _idle_break():
	state_machine.travel("moveset_idle_break")
func _curl():
	state_machine.travel("moveset_curl")
func _curl_break():
	state_machine.travel("moveset_curl_break")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "moveset/idle_break":
		get_parent().breaking_idle = false
		_idle()
