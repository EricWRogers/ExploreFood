extends Node2D

var following := false
const MAX_DIST := 225
var count : int = 0 

func _physics_process(delta: float) -> void:
	var mouseDist := get_global_mouse_position().distance_to( $knob.global_position )
	if mouseDist < MAX_DIST and Input.is_action_just_pressed("Click"):
		following = true
	if Input.is_action_just_released("Click"):
		following = false

	
	if following:
		var ang := get_global_mouse_position().angle_to_point( $knob.global_position ) + PI
		var d :Vector2= ($knob/knobPoint.position.rotated( $knob.rotation))
		var a = $middlePoint.global_position.angle_to(d)
		print (a)
		var finalAng :float= remap( a, -3.14, 3.14, 0, 100 )
		print(finalAng)
		$knob.rotation = ang
		
		#var fang : float= lerp_angle( $knob.rotation, ang, 0.3)
		#$knob.rotation = clamp(fang, -3,8)


func _on_button_pressed() -> void:
	count += 1
	if count == 5:
		print("yum")
	elif count > 5:
		count = 1
	print(count)
