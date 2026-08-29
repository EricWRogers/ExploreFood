extends Node3D

var holding = false
var moving = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_anims():
	if holding == true:
		hold()
		return
	if moving == true:
		run()
	else:
		idle()

func hold():
	$AnimationPlayer.play("Hold")
func run():
	$AnimationPlayer.play("Run")
func idle():
	$AnimationPlayer.play("Hold")
	$AnimationPlayer.stop()
