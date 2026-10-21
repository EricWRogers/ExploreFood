extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 3.5
@export var sprint_speed := 10.6
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var air_control := 8.0
@export var crouch_speed := 2.6

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
var cliff_detect := true
var not_moving := true
var balancing_cliff_edge := false
var breaking_idle := false
var fall_start_height := 0.0
var fell_far_enough := false
var crouching := false

@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %Doremi
@onready var _camera_pivot: Node3D = %CameraPivot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
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
	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching
	var was_grounded := is_on_floor()

	if is_sprinting and was_grounded and move_direction.length() > 0.1 and not crouching:
		%Steps.emitting = true
	else:
		%Steps.emitting = false

	var target_speed := move_speed
	if crouching:
		target_speed = crouch_speed
	elif is_sprinting:
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

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		is_starting_jump = true
		velocity.y = jump_impulse
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
		velocity.y *= 0.6
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
			if is_sprinting and ground_speed > 0.1:
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
