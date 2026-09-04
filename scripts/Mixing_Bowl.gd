extends Node2D

var following := false
const MAX_DIST := 7000

func _physics_process(delta: float) -> void:
	var mouseDist := get_global_mouse_position().distance_squared_to( $knob.global_position )
	if mouseDist < MAX_DIST and Input.is_action_just_pressed("Click"):
		following = true
	if Input.is_action_just_released("Click"):
		following = false
	#print(following)
	
	if following:
		var ang := get_global_mouse_position().angle_to_point( $knob.global_position ) + PI
		print($knob/knobPoint.position.rotated( $knob.rotation))
		print($knob/knobPoint.global_position - global_position)
		$knob.rotation = ang


func _on_button_pressed() -> void:
	print("hi")
