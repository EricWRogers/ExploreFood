extends StaticBody3D

var cooking := false
@export var active: bool = false
# Called when the node enters the scene tree for the first time.
var started
@export_group("Vertical (Y translation)")
@export var y_sensitivity: float = 0.004
@export var min_y_offset: float = 0.0
@export var max_y_offset: float = 0.7
 
@export_group("Horizontal (swirl)")
@export var swirl_sensitivity: float = 0.00005
@export var tilt_degrees: float = 12.0
@export var orbit_radius: float = 0.0
 
@export_group("Feel")
@export var smoothing: float = 12.0  # higher = snappier
 
var base_y: float
var base_pos: Vector3
var base_quat: Quaternion
var y_offset: float = 0.0
var target_phase: float = 0.0
var phase: float = 0.0
var tilt_scale: float = 0.0
var target_tilt_scale: float = 0.0

func _ready() -> void:
	base_pos = position
	base_y = position.y
	base_quat = quaternion
	$Camera3D2.global_position = $CameraFollow.global_position
	$Camera3D2.global_rotation = $CameraFollow.global_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var t := 1.0 - exp(-smoothing * delta)

	phase = lerpf(phase, target_phase, t)
	tilt_scale = lerpf(tilt_scale, target_tilt_scale, t)
	position.y = lerpf(position.y, base_y + y_offset, t)

	# The surface normal leans toward a direction that rotates with `phase`.
	var axis := Vector3(sin(phase), 0.0, -cos(phase))
	quaternion = base_quat * Quaternion(axis, deg_to_rad(tilt_degrees) * tilt_scale)

	if orbit_radius > 0.0:
		position.x = base_pos.x + cos(phase) * orbit_radius * tilt_scale
		position.z = base_pos.z + sin(phase) * orbit_radius * tilt_scale


func return_to_upright(instant: bool = false) -> void:
	target_tilt_scale = 0.0
	y_offset = 0.0
	if instant:
		tilt_scale = 0.0
		position = base_pos
		quaternion = base_quat


func _on_detect_food_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ingredient") and not cooking:
		cooking = true
		if body.can_be_cooked:
			body.can_sleep = false
			$Pan/StaticBody3D.set_collision_layer_value(3, true)
			start_station()
			body._defocus()
			body.global_position = $Pan/SpawnPnt.global_position
			body.pan_grill()
			cooking = true
			#body.pan_grill()
			body.current_station = self
			$Pan/Sizzle.play()
			$Pan/AnimationPlayer.play("cooking")
		else:
			cooking = false
func finished_cooking():
	$Pan/StaticBody3D.set_collision_layer_value(3, false)
	active = false
	return_to_upright()
	$Pan/Sizzle.stop()
	$Pan/AnimationPlayer.stop()
	cooking = false
	$Pan/GPUParticles3D.hide()
	$Pan/Water.hide()
	end_station()
	
func start_station():
	active = true
	target_tilt_scale = 1.0
	$Pan/DetectFood.set_collision_mask_value(2, false)
	for item in get_tree().get_nodes_in_group("Camera"):
		item.current = false
	$Camera3D2.current = true
	started = true
	for item in get_tree().get_nodes_in_group("Player"):
		item.can_move = false
		item.hide()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func end_station():
	#for child in cut_bodies_parent.get_children():
		#if child is RigidBody3D:
			#child.freeze = true
	#cut_bodies_parent.can_be_picked_up = true
	#food_on = true
	$Pan/DetectFood.set_collision_mask_value(2, true)
	$Camera3D2.current = false
	started = false
	for item in get_tree().get_nodes_in_group("Player"):
		item.can_move = true
		item.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if !active:
		return
	if event is InputEventMouseMotion:
		# Mouse up (negative relative.y) raises the pan.
		y_offset = clampf(
			y_offset - event.relative.y * y_sensitivity,
			min_y_offset,
			max_y_offset
		)
		# Moving right sweeps the lean direction around the circle one way,
		# moving left sweeps it back the other way.
		target_phase += event.relative.x * swirl_sensitivity
