extends Camera3D

@export var sensitivity: float = 0.003
@export var base_speed: float = 10.0
@export var fast_multiplier: float = 3.0

var active = false

var rot_x: float = 0.0
var rot_y: float = 0.0

func _ready() -> void:
	rot_x = rotation.x
	rot_y = rotation.y

func _unhandled_input(event: InputEvent) -> void:
	if !active:
		return
	# Look around when holding the Right Mouse Button
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rot_y -= event.relative.x * sensitivity
		rot_x -= event.relative.y * sensitivity
		# Clamp vertical rotation to avoid flipping upside down
		rot_x = clamp(rot_x, deg_to_rad(-89), deg_to_rad(89))
		rotation.x = rot_x
		rotation.y = rot_y

func _process(delta: float) -> void:
	if !active:
		self.global_position = $"../Head/Camera3D".global_position
		self.global_rotation = $"../Head/Camera3D".global_rotation
		return
	var speed = base_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= fast_multiplier
		
	var dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		dir -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		dir += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		dir -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		dir += transform.basis.x
	if Input.is_key_pressed(KEY_Q):
		dir -= transform.basis.y
	if Input.is_key_pressed(KEY_E):
		dir += transform.basis.y
		
	dir = dir.normalized()
	position += dir * speed * delta
