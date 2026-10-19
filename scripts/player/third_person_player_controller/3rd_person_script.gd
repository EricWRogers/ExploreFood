extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 2.6
@export var sprint_speed := 10.6
@export var acceleration := 20.0
@export var rotation_speed := 12
@export var jump_impulse := 12

var _camera_input_direction := Vector2.ZERO
var _last_movement_dir := Vector3.BACK
var _gravity := -30.0
var cliff_detect := true
var not_moving := true
var balancing_cliff_edge := false
var breaking_idle := false

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
	if %CliffEdgeDetect.is_colliding():
		cliff_detect = true
	else:
		cliff_detect = false
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, 
	-PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("Left",
	"Right", "Forward", "Back")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var is_sprinting := Input.is_action_pressed("Sprint")
	var y_velocity := velocity.y
	velocity.y = 0
	if is_sprinting:
		velocity = velocity.move_toward(move_direction * 
		sprint_speed, acceleration * delta)
		velocity.y = y_velocity + _gravity * delta
	else:
		velocity = velocity.move_toward(move_direction * 
		move_speed, acceleration * delta)
		velocity.y = y_velocity + _gravity * delta
	var is_starting_jump := Input.is_action_just_pressed("Jump") and is_on_floor()
	if is_starting_jump:
		not_moving = false
		$IdleBreak.stop()
		$Cliff.stop()
		balancing_cliff_edge = false
		breaking_idle = false
		velocity.y += jump_impulse
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_landed = !was_on_floor and is_on_floor()
	
	if move_direction.length() > 0.2:
		not_moving = false
		$IdleBreak.stop()
		$Cliff.stop()
		balancing_cliff_edge = false
		breaking_idle = false
		_last_movement_dir = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_dir, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	
	if is_starting_jump:
		_skin._jump()
	elif just_landed:
		_skin._land()
	elif !is_on_floor() and velocity.y < 0:
		_skin._fall()
	elif is_on_floor():
		var ground_speed := Vector2(velocity.x, velocity.z).length()

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
		_skin._cliff()
