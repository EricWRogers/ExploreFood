extends CharacterBody3D

@export_group("Camera")
@export var mouse_sensitivity := 0.003
@export var controller_sensitivity := 3.0

@export_group("Movement")
@export var move_speed := 3.5
@export var sprint_speed := 10.6
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var cliff_hang_rot := 50
@export var air_control := 8.0
@export var crouch_speed := 2.6

@export_group("Controls")
@export var _current_input_device: String = "joypad"

@export_group("Jump")
@export var jump_impulse := 12.0
@export var jump_buffer_time := 0.12
@export var coyote_time := 0.12
@export var apex_gravity_multiplier := 0.35
@export var fall_gravity_multiplier := 1.4
@export var jump_cut_multiplier := 2.0

var jump_buffer_timer := 0.0
var coyote_timer := 0.0
var jump_was_cut := false

var _camera_input_direction := Vector2.ZERO
var _last_movement_dir := Vector3.BACK
var _gravity := -30.0
var _gravity_retain := -30.0
var cliff_detect := true
var not_moving := true
var balancing_cliff_edge := false
var breaking_idle := false
var fall_start_height := 0.0
var fell_far_enough := false
var crouching := false
var sprint_toggle := false
var overhead_detect := false
var eyelevel_detect := false
var ingeo_detect_left := false
var ingeo_detect_right := false
var hanging := false
var edge_snap := false
var currently_snapping := false
var climbing := false
var can_ledge_grab := false
var ledge_timer_switch := false
var max_spring_length : float
var climb_started := false
var climbing_detect_started := false
var climbing_detect_has_collided := false

@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %Doremi
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var shadow: SpringArm3D = $Shadow
@onready var decal: Decal = $Shadow/Decal


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_gravity_retain = _gravity
	max_spring_length = shadow.spring_length
#func _input(event: InputEvent) -> void:
	#pass
	#if event is InputEventKey or event is InputEventMouse:
		#_current_input_device = "keyboard_mouse"
		#print("keyboardmouse")
	#elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		#_current_input_device = "joypad"
		#print("joypad")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.screen_relative
func snap_to_edge():
	#snaps character to wall so they dont float#
	if hanging:
		if !edge_snap:
			edge_snap == true
			velocity = _skin.global_transform.basis.z.normalized() * 50
			currently_snapping = true
func freeze_velocity():
	velocity = Vector3.ZERO
func _process(_delta: float) -> void:
	#print(breaking_idle)
	var new_scale: float = shadow.get_hit_length()
	new_scale = 1.0 - (new_scale / max_spring_length)
	new_scale = clamp(new_scale, 0.0, 1.0)
	decal.size = Vector3(new_scale, 1.0, new_scale)
	
func _physics_process(delta: float) -> void:
	#Cliff Hang Stuff#
	
	if currently_snapping and is_on_wall():
		freeze_velocity()
	var area_detect = %DistanceCheck.has_overlapping_bodies()
	overhead_detect = %OverheadDetect.is_colliding()
	eyelevel_detect = %EyelevelDetect.is_colliding()
	ingeo_detect_left = %InGeometryDetectL.is_colliding()
	ingeo_detect_right = %InGeometryDetectR.is_colliding()
	if Input.is_action_just_pressed("Forward") and hanging and !climb_started:
		climbing = true
		climb_started = true
		climbing_detect_has_collided = false
		velocity.y = 3
		_skin._cliff_climb()
	#detect the edge and freeze movement and gravity#
	if area_detect and !overhead_detect and !eyelevel_detect and ingeo_detect_left and ingeo_detect_right and not climbing  and can_ledge_grab:
		var normal: Vector3 = %InGeometryDetect.get_collision_normal()
		var target_angle: float = atan2(normal.x, normal.z) + PI
		_skin.global_rotation.y = lerp_angle(
		_skin.rotation.y,
		target_angle,
		cliff_hang_rot * delta
		)
		velocity = Vector3.ZERO
		_gravity = 0
		_skin._cliff_hang()
		hanging = true
		snap_to_edge()
		#print("climbing")
	#elif not ingeo_detect_left or not ingeo_detect_right:
		#climbing = false
		#hanging = false
		#_gravity = _gravity_retain
		#currently_snapping = false
	#climb up the edge#
	if climbing:
		if %ClimbingDetect.is_colliding():
			climbing_detect_has_collided = true

		if not climbing_detect_has_collided or %ClimbingDetect.is_colliding():
			velocity.y = 3
		else:
			velocity = _skin.global_transform.basis.z.normalized() * 2
			currently_snapping = false

		if %ClimbedUpDetect.is_colliding():
			climbing = false
			hanging = false
			currently_snapping = false
			_gravity = _gravity_retain
			climb_started = false
	var controller_direction := Input.get_vector(
	"look_left",
	"look_right",
	"look_up",
    "look_down"
	)
	_camera_pivot.rotation.x += _camera_input_direction.y * mouse_sensitivity
	_camera_pivot.rotation.y -= _camera_input_direction.x * mouse_sensitivity
	_camera_pivot.rotation.x -= controller_direction.y * controller_sensitivity * delta
	_camera_pivot.rotation.y -= controller_direction.x * controller_sensitivity * delta
	_camera_pivot.rotation.x = clamp(
		_camera_pivot.rotation.x,
		-PI / 6.0,
		PI / 3.0
	)
	_camera_input_direction = Vector2.ZERO
	
	cliff_detect = %CliffEdgeDetect.is_colliding()

	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(
		_camera_pivot.rotation.x,
		-PI / 6.0,
		PI / 3.0
	)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

	var raw_input := Input.get_vector(
		"Left",
		"Right",
		"Forward",
		"Back"
	)

	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	var is_sprinting := Input.is_action_pressed("Sprint")
	var is_sprint_joypad := Input.is_action_just_pressed("Sprint")
	if _current_input_device == "joypad" and is_sprint_joypad:
		sprint_toggle = !sprint_toggle
		#print(sprint_toggle)
	elif _current_input_device == "keyboard_mouse":
		sprint_toggle = false
	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching
	var was_grounded := is_on_floor()

	if is_sprinting and was_grounded and move_direction.length() > 0.1 and not crouching:
		%Steps.emitting = true
	elif sprint_toggle and was_grounded and move_direction.length() > 0.1 and not crouching:
		%Steps.emitting = true
	else:
		%Steps.emitting = false

	var target_speed := move_speed
	if crouching:
		target_speed = crouch_speed
	elif is_sprinting:
		target_speed = sprint_speed
	elif sprint_toggle:
		target_speed = sprint_speed

	var target_velocity := move_direction * target_speed
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)

	if was_grounded:
		if move_direction.length() > 0.0:
			var current_direction := horizontal_velocity.normalized()
			var direction_dot := current_direction.dot(move_direction)
			var accel := acceleration

			if horizontal_velocity.length() > 0.1 and direction_dot < 0.5:
				accel = 80.0

			horizontal_velocity = horizontal_velocity.move_toward(
				target_velocity,
				accel * delta
			)
		else:
			horizontal_velocity = horizontal_velocity.move_toward(
				Vector3.ZERO,
				60.0 * delta
			)
	else:
		if move_direction.length() > 0.0:
			horizontal_velocity = horizontal_velocity.move_toward(
				target_velocity,
				air_control * delta
			)
	if !hanging:
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)

	if was_grounded:
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	var is_starting_jump := false

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0 and not climb_started:
		is_starting_jump = true
		velocity.y = jump_impulse
		%LedgeGrabTimer.start()
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump_was_cut = false

		not_moving = false
		$IdleBreak.stop()
		$Cliff.stop()
		balancing_cliff_edge = false
		breaking_idle = false

	elif Input.is_action_just_pressed("Jump") and !was_grounded:
		%Doremi.mult._fork()

	if Input.is_action_just_released("Jump") and velocity.y > 0.0:
		velocity.y *= 0.8
		jump_was_cut = true

	if !is_starting_jump:
		var gravity_multiplier := 1.0

		if velocity.y > 0.0:
			if absf(velocity.y) < 2.5:
				gravity_multiplier = apex_gravity_multiplier
			elif !Input.is_action_pressed("Jump") and velocity.y > 5.0:
				gravity_multiplier = jump_cut_multiplier
		elif velocity.y < 0.0:
			gravity_multiplier = fall_gravity_multiplier

		velocity.y += _gravity * gravity_multiplier * delta

	var was_on_floor := is_on_floor()
	move_and_slide()
	var just_landed := !was_on_floor and is_on_floor()

	if was_on_floor and !is_on_floor():
		fall_start_height = global_position.y
		fell_far_enough = false

	if !is_on_floor():
		var fall_distance := fall_start_height - global_position.y
		if fall_distance >= 2.0:
			fell_far_enough = true

	if just_landed and fell_far_enough:
		%LandHigh.restart()
		%LandHigh.emitting = true

	if move_direction.length() > 0.2:
		not_moving = false
		$IdleBreak.stop()
		$Cliff.stop()
		balancing_cliff_edge = false
		breaking_idle = false
		_last_movement_dir = move_direction

	var target_angle := Vector3.BACK.signed_angle_to(
		_last_movement_dir,
		Vector3.UP
	)
	if !hanging:
		_skin.global_rotation.y = lerp_angle(
			_skin.rotation.y,
			target_angle,
			rotation_speed * delta
		)

	if Input.is_action_just_pressed("Interact"):
		%Doremi.mult._spoon()

	if is_starting_jump:
		_skin._jump()
	elif just_landed:
		%LandLow.restart()
		%LandLow.emitting = true
		_skin._land()
	elif !is_on_floor() and velocity.y < 0.0:
		_skin._fall()
	elif is_on_floor():
		can_ledge_grab = false
		var ground_speed := Vector2(velocity.x, velocity.z).length()
		if crouching and ground_speed < 0.1 and not just_landed:
			_skin._crouch()
			$IdleBreak.stop()
			$Cliff.stop()
		elif crouching:
			_skin._crouch_walk()
			$IdleBreak.stop()
			$Cliff.stop()
		else:
			if is_sprinting and ground_speed > 0.1 and _current_input_device == "keyboard_mouse":
				_skin._run()
			elif sprint_toggle and ground_speed > 0.1 and _current_input_device == "joypad":
				_skin._run()
			elif ground_speed > 0.1:
				_skin._walk()
			else:
				if !not_moving:
					not_moving = true
					$IdleBreak.start()
					$Cliff.start()

				if !balancing_cliff_edge and !breaking_idle:
					_skin._idle()


func _on_idle_break_timeout() -> void:
	if not_moving and !balancing_cliff_edge:
		breaking_idle = true
		_skin._idle_break()


func _on_cliff_timeout() -> void:
	if !cliff_detect and not_moving:
		balancing_cliff_edge = true
		breaking_idle = false
		$IdleBreak.stop()
		$Cliff.stop()
		_skin._cliff()


func _on_ledge_grab_timer_timeout() -> void:
	can_ledge_grab = true
