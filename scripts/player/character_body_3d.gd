extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 12
const SENSITIVITY = 0.003
var hunger = 100
var hunger_reduction_rate = 5

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var tBob = 0.0
var alive = true

const BASE_FOV = 75.0 # we can make this a var that the player can choose
const FOV_CHANGE = 1.5

var canJump = true;
@export var in_kitchen : bool = false
@export var coyoteTime = 0.1;
@onready var coyote_timer: Timer = $CoyoteTimer

@onready var raycast = $Head/Camera3D/RayCast3D
@onready var food_spawn: Marker3D = $Head/Camera3D/FoodSpawn


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
	if Manager.bagel_mode and not in_kitchen:
		$HungerTick.start()
	else:
		$CanvasLayer/MarginContainer4.hide()
		$CanvasLayer/MarginContainer5.hide()
	$Head/Camera3D.make_current()
	Manager.player_hold = $Head/KillerBeanSproject2/ItemHoldSpawn
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Manager.slot1 != null:
		var get_slot = Manager.slot1.instantiate()
		$CanvasLayer/MarginContainer/Start/Slot1/Panel/Item1.texture = get_slot.icon
	if Manager.slot2 != null:
		var get_slot = Manager.slot2.instantiate()
		$CanvasLayer/MarginContainer/Start/Slot2/Panel/Item2.texture = get_slot.icon
	if Manager.slot3 != null:
		var get_slot = Manager.slot3.instantiate()
		$CanvasLayer/MarginContainer/Start/Slot3/Panel/Item3.texture = get_slot.icon

func _unhandled_input(event):
	if not alive:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	
func _physics_process(delta: float) -> void:
	if not alive:
		if Input.is_action_just_pressed("Jump"):
			get_tree().current_scene.start_loading("terrain_test")
		return
	if Input.is_action_just_pressed("instant_death_button"):
		death()
	# Add the gravity.
	if not is_on_floor():
		if canJump:
			if(coyote_timer.is_stopped()):
				coyote_timer.start(coyoteTime)
		velocity += get_gravity() * 3 * delta
	else:
		canJump = true;
		coyote_timer.stop()

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and canJump:
		velocity.y = JUMP_VELOCITY
		canJump = false;

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
	if Input.is_action_just_pressed("dropthrow"):
		dropthrow()
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

	var forward_speed = -velocity.dot(head.global_transform.basis.z)
	forward_speed = max(forward_speed, 0.0)

	var targetFOV = BASE_FOV + FOV_CHANGE * clamp(forward_speed, 0.5, speed * 2)
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
	if Input.is_action_just_pressed("Interact") and current_target and Manager.inventory.size() < 3:
		if current_target.has_method("get_took"):
			var target_scene: PackedScene
			target_scene = load(current_target.scene_file_path)
			current_target.get_took()
			if Manager.slot1 == null:
				if Manager.bagel_mode:
					Manager.slotb1 = current_target
				Manager.slot1 = target_scene
				$CanvasLayer/MarginContainer/Start/Slot1/Panel/Item1.texture = current_target.icon
				Manager.inventory.append(target_scene)
				update_slots(1)
			elif Manager.slot2 == null:
				if Manager.bagel_mode:
					Manager.slotb2 = current_target
				Manager.slot2 = target_scene
				$CanvasLayer/MarginContainer/Start/Slot2/Panel/Item2.texture = current_target.icon
				Manager.inventory.append(target_scene)
				update_slots(2)
			elif Manager.slot3 == null:
				if Manager.bagel_mode:
					Manager.slotb3 = current_target
				Manager.slot3 = target_scene
				$CanvasLayer/MarginContainer/Start/Slot3/Panel/Item3.texture = current_target.icon
				Manager.inventory.append(target_scene)
				update_slots(3)
	elif Input.is_action_just_pressed("Interact") and current_target and Manager.inventory.size() >= 3:
		if current_target.has_method("get_took"):
			current_target.get_rolled()

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
	var slot_check
	if current_slot != 0:
		slot_check = Manager.get("slot" + str(current_slot))
	if slot_check != null and current_slot != 0:
		Manager.holding = true
		var instance = slot_check.instantiate()
		var id = instance.id
		killer_bean_sproject_2.update_held_item(id)
		killer_bean_sproject_2.hold_setter = false
		killer_bean_sproject_2.update_anims()
	else:
		killer_bean_sproject_2.update_held_item(0)
		Manager.holding = false
		killer_bean_sproject_2.update_anims()
	if Manager.slotb1:
		Manager.slotb1.hide()
	if Manager.slotb2:
		Manager.slotb2.hide()
	if Manager.slotb3:
		Manager.slotb3.hide()
	match current_slot:
		1:
			if Manager.slotb1:
				Manager.slotb1.show()
			selected_1.show()
			selected_2.hide()
			selected_3.hide()
		2:
			if Manager.slotb2:
				Manager.slotb2.show()
			selected_2.show()
			selected_1.hide()
			selected_3.hide()
		3:
			if Manager.slotb3:
				Manager.slotb3.show()
			selected_1.hide()
			selected_2.hide()
			selected_3.show()
		0:
			selected_1.hide()
			selected_2.hide()
			selected_3.hide()
			
func dropthrow():
	if current_slot == 0:
		return
	match current_slot:
		1:
			if Manager.slot1 == null:
				return
			$CanvasLayer/MarginContainer/Start/Slot1/Panel/Item1.texture = null
			var drop = Manager.slot1.instantiate()
			if drop.type == "bagel":
				#drop.freeze = false
				#drop.held = false
				#drop.global_position = food_spawn.global_position
				Manager.slotb1.held = false
				Manager.slotb1.freeze = false
				Manager.slotb1.show()
				Manager.slotb1.set_collision_layer_value(10, true)
				Manager.slotb1 = null
				Manager.slot1 = null
				Manager.inventory.pop_front()
			
				killer_bean_sproject_2.update_held_item(0)
				Manager.holding = false
				killer_bean_sproject_2.update_anims()
				update_slots(0)
				return
			var current_scene = get_tree().current_scene
			drop.rarity_level = 1
			current_scene.add_child(drop)
			drop.freeze = false
			drop.global_position = food_spawn.global_position
			Manager.inventory.pop_front()
			Manager.slot1 = null
			killer_bean_sproject_2.update_held_item(0)
			Manager.holding = false
			killer_bean_sproject_2.update_anims()
			update_slots(0)
		2:
			if Manager.slot2 == null:
				return
			$CanvasLayer/MarginContainer/Start/Slot2/Panel/Item2.texture = null
			var drop = Manager.slot2.instantiate()
			if drop.type == "bagel":
				drop.freeze = false
				drop.global_position = food_spawn.global_position
				Manager.slotb2.held = false
				Manager.slotb2.freeze = false
				Manager.slotb2.show()
				Manager.slotb2.set_collision_layer_value(10, true)
				Manager.slotb2 = null
				Manager.slot2 = null
				Manager.inventory.pop_front()
			
				killer_bean_sproject_2.update_held_item(0)
				Manager.holding = false
				killer_bean_sproject_2.update_anims()
				update_slots(0)
				return
			var current_scene = get_tree().current_scene
			drop.rarity_level = 1
			current_scene.add_child(drop)
			drop.freeze = false
			drop.global_position = food_spawn.global_position
			Manager.inventory.pop_front()
			Manager.slot2 = null
			killer_bean_sproject_2.update_held_item(0)
			Manager.holding = false
			killer_bean_sproject_2.update_anims()
			update_slots(0)
		3:
			if Manager.slot3 == null:
				return
			$CanvasLayer/MarginContainer/Start/Slot3/Panel/Item3.texture = null
			var drop = Manager.slot3.instantiate()
			if drop.type == "bagel":
				drop.freeze = false
				Manager.slotb3.held = false
				Manager.slotb3.freeze = false
				Manager.slotb3.show()
				Manager.slotb3.set_collision_layer_value(10, true)
				Manager.slotb3 = null
				Manager.slot3 = null
				drop.global_position = food_spawn.global_position
				Manager.inventory.pop_front()
				killer_bean_sproject_2.update_held_item(0)
				Manager.holding = false
				killer_bean_sproject_2.update_anims()
				update_slots(0)
				return
			var current_scene = get_tree().current_scene
			drop.rarity_level = 1
			current_scene.add_child(drop)
			drop.freeze = false
			drop.global_position = food_spawn.global_position
			Manager.inventory.pop_front()
			Manager.slot3 = null
			killer_bean_sproject_2.update_held_item(0)
			Manager.holding = false
			killer_bean_sproject_2.update_anims()
			update_slots(0)
		0:
			pass

func CoyoteTimeout():
	canJump = false;
	
func death():
	alive = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Death.play("Appear")
	$Head/RagdollGuy/AnimationPlayer.play("Hold")
	$Head/RagdollGuy/AnimationPlayer.stop()
	$Head/KillerBeanSproject2.hide()
	$"Head/3rdPerson".make_current()
	$Head/RagdollGuy/Skeleton3D/PhysicalBoneSimulator3D.active = true
	$Head/RagdollGuy.show()
	$Head/RagdollGuy.fall()


func _on_hunger_tick_timeout() -> void:
	hunger -= hunger_reduction_rate
	$CanvasLayer/MarginContainer4/VBoxContainer/Control/MarginContainer/HungerBar.set_hunger(hunger)
