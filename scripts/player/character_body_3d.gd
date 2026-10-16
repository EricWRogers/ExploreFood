class_name Player
extends CharacterBody3D

# ─────────────────────────────────────────
# MOVEMENT SETTINGS
# ─────────────────────────────────────────

const BASE_WALK_SPEED: float = 9.0
const BASE_SPRINT_SPEED: float = 12.0
const BASE_JUMP_VELOCITY: float = 12.0
const SENSITIVITY: float = 0.003

@export var dash_speed: float = 55.0
@export var dash_duration: float = 0.025
@export var dash_cooldown: float = 1.0
@export var sprint_tap_threshold: float = 0.3

@export var power_time: float = 15.0

var current_walk_speed: float = BASE_WALK_SPEED
var current_sprint_speed: float = BASE_SPRINT_SPEED
var current_jump_velocity: float = BASE_JUMP_VELOCITY
var speed: float = BASE_WALK_SPEED

var can_jump: bool = true
var jump_count = 2
var is_dashing: bool = false
var dash_direction: Vector3 = Vector3.ZERO
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0

var sprint_press_time: float = 0.0
var sprint_pending: bool = false

const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.08
const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.5

var t_bob: float = 0.0

# ─────────────────────────────────────────
# PLAYER STATE
# ─────────────────────────────────────────

var alive: bool = true
var free_cam: bool = false
var recipe_open: bool = false
var is_first_person: bool = true
var hold_prep: bool = false
var lock_mouse : bool = true

var hunger: float = 100.0
@export var hunger_reduction_rate: float = 2.5

var consume_speed: float = 0.08
var impulse_force: float = 15.0

@export var in_kitchen: bool = false

# ─────────────────────────────────────────
# INVENTORY AND TARGETS
# ─────────────────────────────────────────

var selected_object: Node = null
var current_target: Node = null
var current_slot: int = 0

var hotbar: Array = []

# ─────────────────────────────────────────
# NODE REFERENCES
# ─────────────────────────────────────────

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/FirstPersonCam

@onready var first_person_raycast: RayCast3D = \
	$Head/FirstPersonCam/RayCast3D

@onready var third_person_raycast: RayCast3D = \
	$Head/ThirdPersonCam/Camera3D/RayCast3D

@onready var current_raycast: RayCast3D = first_person_raycast

@onready var food_spawn: Marker3D = \
	$Head/FirstPersonCam/FoodSpawn

@onready var item_hold_spawn: Marker3D = \
	$Head/KillerBeanSproject2/ItemHoldSpawn

@onready var consume_bar: TextureProgressBar = \
	$CanvasLayer/MarginContainer8/ConsumeBar

@onready var selected_1: MarginContainer = \
	$CanvasLayer/MarginContainer/Start/Slot1/Panel/Selected1

@onready var selected_2: MarginContainer = \
	$CanvasLayer/MarginContainer/Start/Slot2/Panel/Selected2

@onready var selected_3: MarginContainer = \
	$CanvasLayer/MarginContainer/Start/Slot3/Panel/Selected3

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var power_up_timer: Timer = $PowerUpTimer


# ─────────────────────────────────────────
# INITIALIZATION
# ─────────────────────────────────────────

func _ready() -> void:
	hunger = Manager.belly
	Manager.player = self
	Manager.player_hold = item_hold_spawn

	$CanvasLayer/MarginContainer4.hide()
	$CanvasLayer/MarginContainer5.hide()

	if not in_kitchen:
		$CanvasLayer/MarginContainer4.show()
		$CanvasLayer/MarginContainer5.show()
	else:
		$CanvasLayer/MarginContainer6.show()

	update_cash()
	_setup_camera()
	_setup_inventory_icons()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if DialogueManager:
		DialogueManager.freeze_player.connect(_on_freeze_player)
		DialogueManager.unfreeze_player.connect(_on_unfreeze_player)


func _setup_camera() -> void:
	if is_first_person:
		camera = $Head/FirstPersonCam
		current_raycast = first_person_raycast
	else:
		camera = $Head/ThirdPersonCam/Camera3D
		current_raycast = third_person_raycast

	camera.make_current()


func _setup_inventory_icons() -> void:
	var slots: Array = [
		Manager.slot1,
		Manager.slot2,
		Manager.slot3
	]

	for i in range(slots.size()):
		if slots[i] == null:
			continue

		var item = slots[i].instantiate()
		var icon_node = get_node(
			"CanvasLayer/MarginContainer/Start/Slot%d/Panel/Item%d"
			% [i + 1, i + 1]
		)

		icon_node.texture = item.icon
		item.free()


func start_hunger() -> void:
	if not in_kitchen:
		$HungerTick.start()


# ─────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if recipe_open or not alive:
		return

	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)

		if is_first_person:
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clampf(
				camera.rotation.x,
				deg_to_rad(-90.0),
				deg_to_rad(90.0)
			)
		else:
			var third_person_pivot: Node3D = $Head/ThirdPersonCam
			third_person_pivot.rotate_x(
				-event.relative.y * SENSITIVITY
			)
			third_person_pivot.rotation.x = clampf(
				third_person_pivot.rotation.x,
				deg_to_rad(-60.0),
				deg_to_rad(60.0)
			)


# ─────────────────────────────────────────
# MAIN PHYSICS LOOP
# ─────────────────────────────────────────

func _physics_process(delta: float) -> void:
	_handle_global_inputs()

	if not alive:
		if Input.is_action_just_pressed("Jump"):
			get_tree().current_scene.start_loading("terrain_test")
		return

	if recipe_open:
		return

	_handle_gameplay_inputs()
	_update_consuming()
	_update_gravity(delta)
	_handle_jump()
	_update_dash(delta)
	_update_movement(delta)
	_update_camera_effects(delta)
	_update_target_detection()
	_handle_interaction()

	move_and_slide()


# ─────────────────────────────────────────
# GLOBAL INPUTS
# ─────────────────────────────────────────

func _handle_global_inputs() -> void:
	if Input.is_action_just_pressed("free_cam"):
		free_cam = not free_cam

		if free_cam:
			$GodMode.make_current()
			$GodMode.active = true
			alive = false
			$CanvasLayer.hide()
		else:
			$CanvasLayer.show()
			$GodMode.active = false
			alive = true
			_setup_camera()

	if Input.is_action_just_pressed("hunger_disable"):
		$HungerTick.stop()
		$CanvasLayer/MarginContainer4.hide()
		$CanvasLayer/MarginContainer5.hide()

	if Input.is_action_just_pressed("toggle_perspective"):
		toggle_camera_perspective()

	if Input.is_action_just_pressed("instant_death_button") and alive:
		death()

	if Input.is_action_just_pressed("belly_expansion"):
		if Manager.money >= 50:
			Manager.money -= 50
			Manager.belly += 50
			update_cash()

	if Input.is_action_just_pressed("recipe_book"):
		recipe_open = not recipe_open

		if recipe_open:
			Manager.recipe_book.appear()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Manager.recipe_book.disappear()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("Exit"):
		lock_mouse = !lock_mouse
		if lock_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _handle_gameplay_inputs() -> void:
	_handle_sprint_input()
	_handle_inventory_input()


# ─────────────────────────────────────────
# DASH AND SPRINT
# ─────────────────────────────────────────

func _handle_sprint_input() -> void:
	if Input.is_action_just_pressed("Sprint"):
		sprint_pending = true
		sprint_press_time = 0.0

	if sprint_pending:
		sprint_press_time += get_physics_process_delta_time()

		if Input.is_action_just_released("Sprint"):
			if sprint_press_time < sprint_tap_threshold:
				start_dash()

			sprint_pending = false

	speed = (
		current_sprint_speed
		if Input.is_action_pressed("Sprint")
		else current_walk_speed
	)


func _update_dash(delta: float) -> void:
	dash_cooldown_left = maxf(0.0, dash_cooldown_left - delta)

	if not is_dashing:
		return

	dash_time_left -= delta

	if dash_time_left <= 0.0:
		is_dashing = false


func start_dash() -> void:
	if is_dashing or dash_cooldown_left > 0.0:
		return
	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Forward", "Back")

	var direction: Vector3 = (
		head.global_transform.basis* Vector3(input_dir.x, 0.0, input_dir.y))

	direction.y = 0.0

	if direction.length_squared() < 0.001:
		direction = -head.global_transform.basis.z
		direction.y = 0.0

	dash_direction = direction.normalized()
	is_dashing = true
	dash_time_left = dash_duration
	dash_cooldown_left = dash_cooldown


# ─────────────────────────────────────────
# GRAVITY, JUMPING AND MOVEMENT
# ─────────────────────────────────────────

func _update_gravity(delta: float) -> void:
	if is_dashing:
		return
	if not is_on_floor():
		if can_jump and coyote_timer.is_stopped():
			coyote_timer.start(0.1)

		velocity += get_gravity() * 3.0 * delta
	else:
		can_jump = true
		jump_count = 2
		coyote_timer.stop()


func _handle_jump() -> void:
	if not Input.is_action_just_pressed("Jump"):
		return

	# First jump or coyote jump
	if can_jump and jump_count > 0:
		velocity.y = current_jump_velocity
		jump_count -= 1
		can_jump = false
		coyote_timer.stop()

	# Double jump while airborne
	elif not is_on_floor() and jump_count > 0:
		velocity.y = current_jump_velocity
		jump_count -= 1


func _update_movement(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector(
		"Left", "Right", "Forward", "Back"
	)

	var direction: Vector3 = (
		head.transform.basis
		* Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()

	if is_dashing:
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		return

	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerpf(
			velocity.x, direction.x * speed, delta * 3.0
		)
		velocity.z = lerpf(
			velocity.z, direction.z * speed, delta * 3.0
		)


# ─────────────────────────────────────────
# CAMERA EFFECTS
# ─────────────────────────────────────────

func _update_camera_effects(delta: float) -> void:
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _head_bob(t_bob)

	var forward_speed: float = maxf(
		-velocity.dot(head.global_transform.basis.z),
		0.0
	)

	var target_fov: float = BASE_FOV + FOV_CHANGE * clampf(
		forward_speed, 0.5, speed * 2.0
	)

	camera.fov = lerpf(camera.fov, target_fov, delta * 5.0)


func _head_bob(time: float) -> Vector3:
	return Vector3(
		cos(time * BOB_FREQ / 2.0) * BOB_AMP,
		sin(time * BOB_FREQ) * BOB_AMP,
		0.0
	)
	# ─────────────────────────────────────────
# CONSUMING ITEMS
# ─────────────────────────────────────────

func _update_consuming() -> void:
	if not Input.is_action_pressed("consume"):
		consume_bar.hide()
		consume_bar.value = 0.0
		consume_speed = 0.08
		return

	if current_slot == 0:
		consume_bar.hide()
		return

	var slot = Manager.get("slot%d" % current_slot)

	if slot == null:
		consume_bar.hide()
		return

	consume_bar.show()

	if consume_bar.value >= 100.0:
		consume_speed = 0.08
		consume_bar.value = 0.0
		consume_held()
	else:
		consume_bar.value += consume_speed
		consume_speed += 0.05


func consume_held() -> void:
	if current_slot == 0:
		return

	var slot_to_consume: int = current_slot
	var food_scene: PackedScene = Manager.get("slot%d" % slot_to_consume)

	if food_scene == null:
		return

	var item = food_scene.instantiate()
	item.rarity_level = 1.0

	power_up(item.id)
	hunger += item.hunger_restore
	item.free()

	Manager.set("slot%d" % slot_to_consume, null)
	_get_slot_icon(slot_to_consume).texture = null
	_remove_inventory_item(slot_to_consume)

	update_slots(0)

	$CanvasLayer/MarginContainer4/VBoxContainer/Control/MarginContainer/HungerBar.set_hunger(hunger)

# ─────────────────────────────────────────
# INVENTORY
# ─────────────────────────────────────────

func _handle_inventory_input() -> void:
	if Input.is_action_just_pressed("slot1"):
		_select_inventory_slot(1)
	elif Input.is_action_just_pressed("slot2"):
		_select_inventory_slot(2)
	elif Input.is_action_just_pressed("slot3"):
		_select_inventory_slot(3)

	if Input.is_action_just_pressed("dropthrow"):
		dropthrow()


func _select_inventory_slot(slot: int) -> void:
	if Manager.held_sandwich:
		update_slots(0)
		return

	update_slots(slot)


func _get_slot_icon(slot: int) -> TextureRect:
	return get_node(
		"CanvasLayer/MarginContainer/Start/Slot%d/Panel/Item%d"
		% [slot, slot]
	)


func _remove_inventory_item(slot: int) -> void:
	var food_scene = Manager.get("slot%d" % slot)

	if food_scene != null:
		Manager.inventory.erase(food_scene)



func update_slots(slot: int) -> void:
	if slot == current_slot:
		current_slot = 0
	else:
		current_slot = slot

	selected_1.hide()
	selected_2.hide()
	selected_3.hide()

	if is_instance_valid(selected_object):
		selected_object.queue_free()
		selected_object = null

	if current_slot == 0:
		Manager.holding = false
		Manager.current_slot = 0
		return

	var food_scene: PackedScene = Manager.get("slot%d" % current_slot)

	if food_scene == null:
		current_slot = 0
		Manager.holding = false
		Manager.current_slot = 0
		return

	selected_object = food_scene.instantiate()
	selected_object.rarity_level = 1
	add_child(selected_object)

	selected_object.global_position = item_hold_spawn.global_position
	selected_object.scale = Vector3.ONE * 0.25
	selected_object.freeze = true
	selected_object.collision_layer = 2
	selected_object.collision_mask = 2
	selected_object.reparent(item_hold_spawn)

	Manager.holding = true
	Manager.current_slot = current_slot

	match current_slot:
		1:
			selected_1.show()
		2:
			selected_2.show()
		3:
			selected_3.show()


func pickup_food() -> void:
	if not current_target.has_method("get_took"):
		return

	var food_scene: PackedScene = load(current_target.scene_file_path)

	var empty_slot: int = 0
	for i in range(1, 4):
		if Manager.get("slot%d" % i) == null:
			empty_slot = i
			break

	if empty_slot == 0:
		current_target.get_rolled()
		return

	if current_target.has_method("im_food"):
		hold_prep = current_target.is_prepped

	var item_icon = current_target.icon
	var item_id = current_target.id

	current_target.get_took()

	Manager.set("slot%d" % empty_slot, food_scene)
	_get_slot_icon(empty_slot).texture = item_icon

	if not Manager.inventory.has(food_scene):
		Manager.inventory.append(food_scene)

	update_slots(empty_slot)
	update_held_item(item_id)


func dropthrow() -> void:
	if current_slot == 0:
		return

	var slot_to_drop: int = current_slot
	var food_scene: PackedScene = Manager.get("slot%d" % slot_to_drop)

	if food_scene == null:
		update_slots(0)
		return

	var drop = food_scene.instantiate()

	# Set properties BEFORE add_child() triggers _ready().
	drop.rarity_level = 1.0
	drop.freeze = false

	if drop.has_method("im_food"):
		drop.is_prepped = hold_prep

	get_tree().current_scene.add_child(drop)

	drop.global_position = food_spawn.global_position

	var forward_dir = -$Head/FirstPersonCam.global_transform.basis.z
	drop.apply_central_impulse(forward_dir * impulse_force)

	Manager.set("slot%d" % slot_to_drop, null)
	_get_slot_icon(slot_to_drop).texture = null
	_remove_inventory_item(slot_to_drop)

	update_slots(0)
	


func _finish_drop() -> void:
	Manager.holding = false
	update_slots(0)


# ─────────────────────────────────────────
# TARGET DETECTION AND INTERACTION
# ─────────────────────────────────────────

func _update_target_detection() -> void:
	if current_raycast.is_colliding():
		var new_target = current_raycast.get_collider()

		if current_target != new_target:
			if current_target:
				_exit_target()

			current_target = new_target
			_enter_target()
	elif current_target:
		_exit_target()


func _handle_interaction() -> void:
	if not Input.is_action_just_pressed("Interact") or not current_target:
		return

	if Manager.held_sandwich:
		update_slots(0)
		return

	if current_target.has_method("assemble"):
		current_target.assemble()
	elif current_target.has_method("absorb"):
		current_target.holder = item_hold_spawn
	elif current_target.has_method("start_rush_hour"):
		current_target.start_rush_hour()
	else:
		pickup_food()


func _enter_target() -> void:
	if current_target.has_method("on_looked_at"):
		current_target.on_looked_at()


func _exit_target() -> void:
	if is_instance_valid(current_target):
		if current_target.has_method("on_looked_away"):
			current_target.on_looked_away()

	current_target = null


# ─────────────────────────────────────────
# CAMERA SWITCHING
# ─────────────────────────────────────────

func toggle_camera_perspective() -> void:
	is_first_person = not is_first_person
	_setup_camera()


# ─────────────────────────────────────────
# MONEY AND HUNGER
# ─────────────────────────────────────────

func update_cash() -> void:
	$CanvasLayer/MarginContainer6/Money.text = str("$", Manager.money)


func _on_hunger_tick_timeout() -> void:
	hunger -= hunger_reduction_rate
	$HungerTick.wait_time = 2.0

	$CanvasLayer/MarginContainer4/VBoxContainer/Control/MarginContainer/HungerBar.set_hunger(hunger)


# ─────────────────────────────────────────
# JUMP AND DEATH
# ─────────────────────────────────────────

func CoyoteTimeout() -> void:
	can_jump = false


func death() -> void:
	alive = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	$Death.play("Appear")
	$Head/RagdollGuy/AnimationPlayer.play("Hold")
	$Head/RagdollGuy/AnimationPlayer.stop()
	$Head/KillerBeanSproject2.hide()

	$Head/ThirdPersonCam/Camera3D.make_current()
	$Head/RagdollGuy/Skeleton3D/PhysicalBoneSimulator3D.active = true
	$Head/RagdollGuy.show()
	$Head/RagdollGuy.fall()


# ─────────────────────────────────────────
# DIALOGUE FREEZE
# ─────────────────────────────────────────

func _on_freeze_player() -> void:
	set_physics_process(false)


func _on_unfreeze_player() -> void:
	set_physics_process(true)


# ─────────────────────────────────────────
# RECIPE UNLOCKS
# ─────────────────────────────────────────

func update_held_item(id: int) -> void:
	var recipe_ids: Dictionary = {
		1: "terry",
		2: "waffle",
		3: "butter",
		4: "chknandwaffles",
		5: "babytear",
		6: "meatpocket",
		7: "doughbaby",
		8: "meatball"
	}

	if not recipe_ids.has(id):
		return

	var recipe_name: String = recipe_ids[id]
	Manager.recipe_book.unlock_icons(recipe_name)
	Manager.recipe_book.items["ingredients"][recipe_name]["unlocked"] = true


# ─────────────────────────────────────────
# POWER-UPS
# ─────────────────────────────────────────

func speed_power_up() -> void:
	if power_up_timer.is_stopped():
		power_up_timer.start(power_time)
		current_walk_speed *= 2.0
		current_sprint_speed *= 2.0


func jump_power_up() -> void:
	if power_up_timer.is_stopped():
		power_up_timer.start(power_time)
		current_jump_velocity *= 1.5


func _on_power_up_timer_timeout() -> void:
	current_walk_speed = BASE_WALK_SPEED
	current_sprint_speed = BASE_SPRINT_SPEED
	current_jump_velocity = BASE_JUMP_VELOCITY


func power_up(id: int) -> void:
	match id:
		1, 2, 3, 4:
			speed_power_up()
		5, 6, 7, 8:
			jump_power_up()
