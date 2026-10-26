extends Node3D

var state_machine = AnimationNodeStateMachinePlayback
@onready var anim_tree = %AnimationTree
@onready var mult: Node3D = %mult
@onready var item_attachment: BoneAttachment3D = %ItemAttachment

var is_holding = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = %AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	
func _update_held_size(size):
	anim_tree.set("parameters/moveset_idle/Blend3/blend_amount", size)
	anim_tree.set("parameters/moveset_run/Blend3/blend_amount", size)
	anim_tree.set("parameters/moveset_walk/Blend3/blend_amount", size)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var amount = 1.0 if is_holding else 0.0

	anim_tree.set("parameters/moveset_idle/Blend2/blend_amount", amount)
	anim_tree.set("parameters/moveset_run/Blend2/blend_amount", amount)
	anim_tree.set("parameters/moveset_walk/Blend2/blend_amount", amount)
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
func _crouch():
	state_machine.travel("moveset_crouch_stand")
func _crouch_walk():
	state_machine.travel("moveset_crouch_walk")
func _cliff_hang():
	state_machine.travel("moveset_cliff_hang")
func _cliff_climb():
	state_machine.travel("moveset_cliff_climbing")

func _footstep():
	get_parent().footstep()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "moveset/idle_break":
		print("yo")
		get_parent().breaking_idle = false
		_idle()
