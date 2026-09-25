extends Node2D

#signal turnedKnob

var following := false
const MAX_DIST := 225
var count : int = 0 
var rng = RandomNumberGenerator.new()
var my_random_number : int

func _ready() -> void:
	$"../Button/ColorIndicator".modulate = Color (1, 0, 0)
	my_random_number = rng.randi_range(1, 5)
	print(my_random_number)

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
		#$knob.rotation = ang
		
		var fang : float= lerp_angle( $knob.rotation, ang, 0.3)
		$knob.rotation = clamp(fang, -4,1)
		#emit_signal("turnedKnob")


func _on_button_pressed() -> void:
	count += 1
	if count == my_random_number:
		print("yum")
		$"../Button/ColorIndicator".modulate = Color (0, 1, 0)
	elif count > my_random_number:
		count = 1
		$"../Button/ColorIndicator".modulate = Color (1, 0, 0)
	print(count)
