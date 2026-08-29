extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 12
const SENSITIVITY = 0.003

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var tBob = 0.0

const BASE_FOV = 75.0 # we can make this a var that the player can choose
const FOV_CHANGE = 1.5

@onready var raycast = $Head/Camera3D/RayCast3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var killer_bean_sproject_2: Node3D = $Head/KillerBeanSproject2
@onready var selected_1: MarginContainer = $CanvasLayer/MarginContainer/Start/Slot1/Panel/Selected1
@onready var selected_2: MarginContainer = $CanvasLayer/MarginContainer/Start/Slot2/Panel/Selected2
@onready var selected_3: MarginContainer = $CanvasLayer/MarginContainer/Start/Slot3/Panel/Selected3

var hotbar = []
var current_target: Node = null
var current_slot = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 3 * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	if Input.is_action_just_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("slot1"):
		update_slots(1)
	elif Input.is_action_just_pressed("slot2"):
		update_slots(2)
	elif Input.is_action_just_pressed("slot3"):
		update_slots(3)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			killer_bean_sproject_2.update_anims()
			killer_bean_sproject_2.moving = true
		else:
			killer_bean_sproject_2.update_anims()
			killer_bean_sproject_2.moving = false
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	tBob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = HeadBob(tBob)
	
	var targetFOV = BASE_FOV + FOV_CHANGE * (clamp(velocity.length(), 0.5, speed * 2))
	camera.fov = lerp(camera.fov, targetFOV, delta * 5.0)
	
	if raycast.is_colliding():
		var new_target = raycast.get_collider()
		if current_target and current_target != new_target:
			_exit_target()
		if current_target != new_target:
			current_target = new_target
			_enter_target()
	else:
		if current_target:
			_exit_target()
	
	move_and_slide()

func HeadBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
	
func _enter_target():
	if current_target.has_method("on_looked_at"):
		current_target.on_looked_at()

func _exit_target():
	if current_target.has_method("on_looked_away"):
		current_target.on_looked_away()
	current_target = null
	
func update_slots(slot):
	if slot != current_slot:
		current_slot = slot
		#equip new item
	elif slot == current_slot:
		current_slot = 0
		#unequip current item
	match current_slot:
		1:
			selected_1.show()
			selected_2.hide()
			selected_3.hide()
		2:
			selected_2.show()
			selected_1.hide()
			selected_3.hide()
		3:
			selected_1.hide()
			selected_2.hide()
			selected_3.show()
		0:
			selected_1.hide()
			selected_2.hide()
			selected_3.hide()
