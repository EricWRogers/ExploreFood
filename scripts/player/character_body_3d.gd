class_name Player extends CharacterBody3D

var speed 
const WALK_SPEED = 7.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 12
const SENSITIVITY = 0.003
#var belly = 100
var hunger = 100
@export var hunger_reduction_rate = 2.5
var time_tick = 2

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var tBob = 0.0
var alive = true
var consume_speed = 0.08

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
@onready var consume_bar: TextureProgressBar = $CanvasLayer/MarginContainer8/ConsumeBar

@onready var killer_bean_sproject_2: Node3D = $Head/KillerBeanSproject2
@onready var selected_1: MarginContainer = $CanvasLayer/MarginContainer/Start/Slot1/Panel/Selected1
@onready var selected_2: MarginContainer = $CanvasLayer/MarginContainer/Start/Slot2/Panel/Selected2
@onready var selected_3: MarginContainer = $CanvasLayer/MarginContainer/Start/Slot3/Panel/Selected3
@onready var item_hold_spawn: Marker3D = $Head/KillerBeanSproject2/ItemHoldSpawn

var selected_object: Node = null
var hotbar = []
var current_target: Node = null
var current_slot = 0
var recipe_open = false
var free_cam = false

func _ready():
	hunger = Manager.belly
	update_cash()
	$CanvasLayer/MarginContainer4.hide()
	$CanvasLayer/MarginContainer5.hide()
	if not in_kitchen:
		$CanvasLayer/MarginContainer4.show()
		$CanvasLayer/MarginContainer5.show()
	Manager.player = self
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
	
	#signals that freeze player movement when talking.
	if (DialogueManager):
		DialogueManager.freeze_player.connect(_on_freeze_player)
		DialogueManager.unfreeze_player.connect(_on_unfreeze_player)


func start_hunger():
	if not in_kitchen:
		$HungerTick.start()
	

func _unhandled_input(event):
	if recipe_open:
		return
	if not alive:
		return
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
func update_cash():
	$CanvasLayer/MarginContainer6/Money.text = str("$",Manager.money)
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("free_cam"):
		free_cam = !free_cam
		if free_cam:
			$GodMode.make_current()
			$GodMode.active = true
			alive = false
			$CanvasLayer.hide()
		else:
			$CanvasLayer.show()
			$GodMode.active = false
			alive = true
			$Head/Camera3D.make_current()

	if Input.is_action_just_pressed("hunger_disable"):
		$HungerTick.stop()
		$CanvasLayer/MarginContainer4.hide()
		$CanvasLayer/MarginContainer5.hide()

	if in_kitchen:
		$CanvasLayer/MarginContainer6.show()

	if not alive:
		if Input.is_action_just_pressed("Jump"):
			get_tree().current_scene.start_loading("terrain_test")
		return

	if Input.is_action_just_pressed("instant_death_button"):
		death()

	if Input.is_action_just_pressed("belly_expansion") and Manager.money >= 50:
		Manager.money -= 50
		update_cash()
		Manager.belly += 50

	if Input.is_action_just_pressed("recipe_book"):
		if recipe_open:
			Manager.recipe_book.disappear()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Manager.recipe_book.appear()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		recipe_open = !recipe_open

	if recipe_open:
		return

	# Consume held item
	if Input.is_action_pressed("consume"):
		var slot = Manager.get("slot%d" % current_slot) if current_slot else null

		if slot:
			consume_bar.show()

			if consume_bar.value >= 100:
				consume_speed = 0.08
				consume_bar.value = 0
				consume_held()
			else:
				consume_bar.value += consume_speed
				consume_speed += 0.05
	else:
		consume_bar.hide()
		consume_bar.value = 0
		consume_speed = 0.08

	# Gravity
	if not is_on_floor():
		if canJump and coyote_timer.is_stopped():
			coyote_timer.start(coyoteTime)
		velocity += get_gravity() * 3 * delta
	else:
		canJump = true
		coyote_timer.stop()

	# Jump
	if Input.is_action_just_pressed("Jump") and canJump:
		velocity.y = JUMP_VELOCITY
		canJump = false

	# Sprint
	speed = SPRINT_SPEED if Input.is_action_pressed("Sprint") else WALK_SPEED

	if Input.is_action_just_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Inventory slots
	if Input.is_action_just_pressed("slot1"):
		update_slots(1)
	elif Input.is_action_just_pressed("slot2"):
		update_slots(2)
	elif Input.is_action_just_pressed("slot3"):
		update_slots(3)

	if Input.is_action_just_pressed("dropthrow"):
		dropthrow()

	# Movement
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			#killer_bean_sproject_2.update_anims()
			#killer_bean_sproject_2.moving = true
		else:
			#killer_bean_sproject_2.update_anims()
			#killer_bean_sproject_2.moving = false
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Head bob
	tBob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = HeadBob(tBob)

	# FOV
	var forward_speed := -velocity.dot(head.global_transform.basis.z)
	forward_speed = max(forward_speed, 0.0)

	var targetFOV = BASE_FOV + FOV_CHANGE * clamp(forward_speed, 0.5, speed * 2)
	camera.fov = lerp(camera.fov, targetFOV, delta * 5.0)

	# Target detection
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

	# Pick up item
	if Input.is_action_just_pressed("Interact") and current_target:
		if current_target.has_method("assemble"):
			current_target.assemble()
		else:
			pickup_food()

	move_and_slide()

func pickup_food() -> void:
	if not current_target.has_method("get_took"):
		return

	if Manager.inventory.size() >= 3:
		current_target.get_rolled()
		return

	var food_scene: PackedScene = load(current_target.scene_file_path)

	current_target.get_took()

	for i in range(1, 4):
		if Manager.get("slot%d" % i) == null:
			Manager.set("slot%d" % i, food_scene)

			get_node(
				"CanvasLayer/MarginContainer/Start/Slot%d/Panel/Item%d" % [i, i]
			).texture = current_target.icon

			Manager.inventory.append(food_scene)
			update_slots(i)

			# Unlock the corresponding recipe/ingredient.
			update_held_item(current_target.id)

			return

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
	
func update_slots(slot: int) -> void:
	# Toggle the current slot.
	if slot == current_slot:
		current_slot = 0
	else:
		current_slot = slot

	# Hide indicators.
	selected_1.hide()
	selected_2.hide()
	selected_3.hide()

	# Delete currently held object.
	if is_instance_valid(selected_object):
		selected_object.queue_free()
		selected_object = null

	# Nothing selected.
	if current_slot == 0:
		Manager.holding = false
		Manager.current_slot = 0
		return

	# Get food scene.
	var food_scene: PackedScene = Manager.get("slot%d" % current_slot)

	if food_scene == null:
		current_slot = 0
		Manager.holding = false
		Manager.current_slot = 0
		return
	# Create new object.
	selected_object = food_scene.instantiate()
	selected_object.rarity_level = 1
	add_child(selected_object)

	selected_object.global_position = item_hold_spawn.global_position
	selected_object.scale = Vector3(0.5, 0.5, 0.5)
	selected_object.freeze = true
	selected_object.collision_layer = 2
	selected_object.collision_mask = 2
	selected_object.reparent(item_hold_spawn)

	Manager.holding = true
	Manager.current_slot = current_slot

	# Show indicator.
	match current_slot:
		1:
			selected_1.show()
		2:
			selected_2.show()
		3:
			selected_3.show()



			
func consume_held() -> void:
	if current_slot == 0:
		return

	var slot = Manager.get("slot%d" % current_slot)
	if slot == null:
		return

	var item_texture = get_node(
		"CanvasLayer/MarginContainer/Start/Slot%d/Panel/Item%d" % [current_slot, current_slot]
	)
	item_texture.texture = null

	var item = slot.instantiate()
	hunger += item.hunger_restore

	Manager.set("slot%d" % current_slot, null)
	Manager.inventory.pop_front()

	#killer_bean_sproject_2.update_held_item(0)
	Manager.holding = false
	#killer_bean_sproject_2.update_anims()
	update_slots(0)

	$CanvasLayer/MarginContainer4/VBoxContainer/Control/MarginContainer/HungerBar.set_hunger(hunger)

			
func dropthrow() -> void:
	if current_slot == 0:
		return

	var slot = Manager.get("slot%d" % current_slot)
	if slot == null:
		return

	# Clear the inventory UI slot.
	var item_texture = get_node(
		"CanvasLayer/MarginContainer/Start/Slot%d/Panel/Item%d" % [current_slot, current_slot]
	)
	item_texture.texture = null

	# Spawn the dropped item.
	var drop = slot.instantiate()
	var current_scene = get_tree().current_scene

	drop.rarity_level = 1
	current_scene.add_child(drop)
	drop.freeze = false
	drop.global_position = food_spawn.global_position

	# Clear the inventory slot.
	Manager.set("slot%d" % current_slot, null)
	Manager.inventory.pop_front()

	_finish_drop()


func _finish_drop() -> void:
	#killer_bean_sproject_2.update_held_item(0)
	Manager.holding = false
	#killer_bean_sproject_2.update_anims()
	update_slots(0)

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
	$HungerTick.wait_time = 2
	$CanvasLayer/MarginContainer4/VBoxContainer/Control/MarginContainer/HungerBar.set_hunger(hunger)

func _on_freeze_player():
	print("Freeze")
	set_physics_process(false)

func _on_unfreeze_player():
	print("unfreeze")
	set_physics_process(true)

func update_held_item(id):
	match id:
		0:
			pass
		1:
			Manager.recipe_book.unlock_icons("terry")
			Manager.recipe_book.items["ingredients"]["terry"]["unlocked"] = true
		2:
			Manager.recipe_book.unlock_icons("waffle")
			Manager.recipe_book.items["ingredients"]["waffle"]["unlocked"] = true
		3:
			Manager.recipe_book.unlock_icons("butter")
			Manager.recipe_book.items["ingredients"]["butter"]["unlocked"] = true
		4:
			Manager.recipe_book.unlock_icons("chknandwaffles")
			Manager.recipe_book.items["ingredients"]["chknandwaffles"]["unlocked"] = true
		5:
			Manager.recipe_book.unlock_icons("babytear")
			Manager.recipe_book.items["ingredients"]["babytear"]["unlocked"] = true
		6:
			Manager.recipe_book.unlock_icons("meatpocket")
			Manager.recipe_book.items["ingredients"]["meatpocket"]["unlocked"] = true
		7:
			Manager.recipe_book.unlock_icons("doughbaby")
			Manager.recipe_book.items["ingredients"]["doughbaby"]["unlocked"] = true
		8:
			Manager.recipe_book.unlock_icons("meatball")
			Manager.recipe_book.items["ingredients"]["meatball"]["unlocked"] = true
		9:
			pass
