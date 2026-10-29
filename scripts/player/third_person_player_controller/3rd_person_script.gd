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

@export_group("Powers")
@export var max_hotbar_slots := 6

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
var grab_candidates := []
var grab_focus : RigidBody3D
var current_taken_slots := 0
var inventory: Array = [null, null, null, null, null, null]
var total_viewers := 1
var held_item_appeared := false
var is_holding := false
const GRAB_GROUPS := ["Ingredient", "Item"]


@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %Doremi
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var shadow: SpringArm3D = $Shadow
@onready var decal: Decal = $Shadow/Decal
@onready var inventory_viewer = preload("res://fp_scenes/inventory/inventory_icon_maker.tscn")
@onready var food_hold_pnt: Marker3D = $Doremi/Skeleton3D/ItemAttachment/FoodHoldPnt
@onready var held_item: AnimationPlayer = $HeldItem


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_gravity_retain = _gravity
	max_spring_length = shadow.spring_length
	
## attempt at making controller input auto switch (doesnt work)
#func _input(event: InputEvent) -> void:
	#pass
	#if event is InputEventKey or event is InputEventMouse:
		#_current_input_device = "keyboard_mouse"
		#print("keyboardmouse")
	#elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		#_current_input_device = "joypad"
		#print("joypad")
## camera movement
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.screen_relative
		
## snaps player to edge when ledge grab
func snap_to_edge():
	if hanging:
		if !edge_snap:
			edge_snap == true
			velocity = _skin.global_transform.basis.z.normalized() * 50
			currently_snapping = true
## freeze no movement when ledged
func freeze_velocity():
	velocity = Vector3.ZERO
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("dropthrow") and Manager.player_current_hovered_slot != -1:
		dropthrow()
	var new_scale: float = shadow.get_hit_length()
	new_scale = 1.0 - (new_scale / max_spring_length)
	new_scale = clamp(new_scale, 0.0, 1.0)
	decal.size = Vector3(new_scale, 1.0, new_scale)
	
	## checks closest items and focus/unfocus them
	var closest : RigidBody3D = null
	var closest_distance: float = INF
	for item in grab_candidates:
		if item.is_in_group("Item") and not item.can_be_picked_up:
			continue
		var current = global_position.distance_to(item.global_position)
		if current < closest_distance:
			closest_distance = current
			closest = item

	unfocus_all()
	grab_focus = closest
	if grab_focus == null:
		return
	grab_focus._focus_obtain()
	## if focused and press interact it picks the item up
	if Input.is_action_just_pressed("Interact") and grab_focus:
		var target_slot: int = Manager.player_current_hovered_slot

		if target_slot < 0 or target_slot >= inventory.size() or inventory[target_slot] != null:
			target_slot = -1

			for i in range(inventory.size()):
				if inventory[i] == null:
					target_slot = i
					break

		if target_slot == -1:
			return

		inventory[target_slot] = grab_focus

		$CanvasLayer/MarginContainer/Hotbar.select_slot(target_slot)
		grab_focus._held_slot = Manager.player_current_hovered_slot
		grab_focus._become_held($Doremi/Skeleton3D/ItemAttachment/FoodHoldPnt)

		for item in inventory:
			if item != null:
				item._become_stored()

		if inventory[target_slot] != null:
			inventory[target_slot]._become_visibly_held()
			%Doremi.is_holding = true
			is_holding = true
			if is_on_floor():
				held_item_appeared = false
			_play_held_item_appear()

		grab_focus.global_position = $Doremi/Skeleton3D/ItemAttachment/FoodHoldPnt.global_position
		current_taken_slots += 1
		_on_item_picked_up(grab_focus, target_slot)
		spawn_inventory_slot_viewer(grab_focus, target_slot)
		print("Item stored in slot: ", target_slot)
func _on_item_picked_up(item: RigidBody3D, slot: int) -> void:
	match _get_grab_kind(item):
		&"ingredient":
			pass  # ingredient-only pickup behavior
		&"item":
			pass  # generic item pickup behavior

func _on_item_dropped(item: RigidBody3D) -> void:
	match _get_grab_kind(item):
		&"ingredient":
			pass
		&"item":
			pass
		
func _get_grab_kind(body: Node) -> StringName:
	if body.is_in_group("Ingredient"):
		return &"ingredient"
	if body.is_in_group("Item"):
		return &"item"
	return &""

func dropthrow():
		var current_drop = Manager.player_current_hovered_slot
		for item in inventory:
			if item != null:
				if item._held_slot == Manager.player_current_hovered_slot:
					item.last_dir = _last_movement_dir
					%Doremi.is_holding = false
					current_taken_slots -= 1
					_on_item_dropped(item)
					item._become_dropped()
					var inv_ndx = inventory.find(item)
					if inv_ndx != -1:
						var viewer_family = get_tree().get_nodes_in_group("Viewer")
						inventory[inv_ndx] = null
						for view in viewer_family:
							if view.slot_tie == inv_ndx:
								view.reset_item()
					#print(inventory)
					break
		
## spawns the scene that displays hotb ar icons
func spawn_inventory_slot_viewer(item, tie):
	var viewer_family = get_tree().get_nodes_in_group("Viewer")

	for view in viewer_family:
		if view.slot_tie == tie:
			view.reset_item()
			view.spawn_item(item)
			$CanvasLayer/MarginContainer/Hotbar._update_visual(tie)
			return

	var viewer = inventory_viewer.instantiate()
	viewer.slot_tie = tie
	viewer.add_to_group("Viewer")
	get_tree().root.add_child(viewer)

	total_viewers += 1
	#viewer.global_position = Vector3(0, -10 * total_viewers, 0)

	viewer._set_FOV(item.inventory_icon_FOV)
	viewer.spawn_item(item)

	$CanvasLayer/MarginContainer/Hotbar._update_visual(tie)
## makes sure no random items stay focused
func unfocus_all():
	for group in GRAB_GROUPS:
		for item in get_tree().get_nodes_in_group(group):
			item._defocus()
## supposed to get the floor mat but i dont know if this works
func footstep() -> void: $SoundsLib.get_surface_play_footsteps(%ClimbedUpDetect)
func _physics_process(delta: float) -> void:
	## cliff hanging logic
	if currently_snapping and is_on_wall():
		freeze_velocity()
	var area_detect = %DistanceCheck.has_overlapping_bodies()
	overhead_detect = %OverheadDetect.is_colliding()
	eyelevel_detect = %EyelevelDetect.is_colliding()
	ingeo_detect_left = %InGeometryDetectL.is_colliding()
	ingeo_detect_right = %InGeometryDetectR.is_colliding()
	if hanging and !climb_started:
		climbing = true
		climb_started = true
		climbing_detect_has_collided = false
		velocity.y = 3
		_skin._cliff_climb()
		_play_held_item_put_away()
	## detect edge and freeze vel
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
		_play_held_item_put_away()
		hanging = true
		snap_to_edge()
	## climbs up the ledge like a horse chess piece
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
	## controller camera movement
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
## basic movement
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
## acceleration and air control
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
	## jump buffer and coyote time
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
## lunge here
	elif Input.is_action_just_pressed("Jump") and !was_grounded:
		%Doremi.mult._fork()
## small hops
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
## checks to see if land should spawn big particles
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
## interupt idle breaks
	if move_direction.length() > 0.2:
		not_moving = false
		$IdleBreak.stop()
		$Cliff.stop()
		balancing_cliff_edge = false
		breaking_idle = false
		_last_movement_dir = move_direction
## smoothly rotate character
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
## large hop here
	if Input.is_action_just_pressed("Interact"):
		%Doremi.mult._spoon()
## complicated logic for animations
	if is_starting_jump:
		_skin._jump()
		_play_held_item_put_away()
	elif just_landed:
		%LandLow.restart()
		%LandLow.emitting = true
		_skin._land()
		_play_held_item_put_away()
	elif !is_on_floor() and velocity.y < 0.0:
		_skin._fall()
		_play_held_item_put_away()
	elif is_on_floor():
		can_ledge_grab = false
		var ground_speed := Vector2(velocity.x, velocity.z).length()
		if crouching and ground_speed < 0.1 and not just_landed:
			_skin._crouch()
			$IdleBreak.stop()
			$Cliff.stop()
			_play_held_item_put_away()
		elif crouching:
			_skin._crouch_walk()
			$IdleBreak.stop()
			$Cliff.stop()
			_play_held_item_put_away()
		else:
			if is_sprinting and ground_speed > 0.1 and _current_input_device == "keyboard_mouse":
				_skin._run()
				_play_held_item_appear()
			elif sprint_toggle and ground_speed > 0.1 and _current_input_device == "joypad":
				_skin._run()
				_play_held_item_appear()
			elif ground_speed > 0.1:
				_skin._walk()
				_play_held_item_appear()
			else:
				if !not_moving:
					not_moving = true
					$IdleBreak.start()
					$Cliff.start()

				if !balancing_cliff_edge and !breaking_idle:
					_skin._idle()
					_play_held_item_appear()
## idle break
func _on_idle_break_timeout() -> void:
	if not_moving and !balancing_cliff_edge:
		breaking_idle = true
		_skin._idle_break()
		_play_held_item_put_away()

## clumsy cliff idle break
func _on_cliff_timeout() -> void:
	if !cliff_detect and not_moving:
		balancing_cliff_edge = true
		breaking_idle = false
		$IdleBreak.stop()
		$Cliff.stop()
		_skin._cliff()
		_play_held_item_put_away()


func _on_ledge_grab_timer_timeout() -> void:
	can_ledge_grab = true

func _on_item_detect_body_entered(body: Node3D) -> void:
	if _get_grab_kind(body) != &"" and not grab_candidates.has(body):
		grab_candidates.append(body)

func _on_item_detect_body_exited(body: Node3D) -> void:
	grab_candidates.erase(body)  # erase is a no-op if it isn't in the array
## updates what item is visibly held
func _on_hotbar_update_held(slot_index) -> void:
	for item in inventory:
		if item != null:
			item._become_stored()
	if slot_index < 0 or slot_index >= inventory.size():
		%Doremi.is_holding = false
		is_holding = false
		_play_held_item_put_away()
		return
	if inventory[slot_index] != null:
		inventory[slot_index]._become_visibly_held()
		%Doremi.is_holding = true
		is_holding = true
		if is_on_floor():
				held_item_appeared = false
		_play_held_item_appear()
	else:
		%Doremi.is_holding = false
		is_holding = false
		_play_held_item_put_away()
## animation logic for pulling out and putting away items
func _play_held_item_appear() -> void:
	if held_item_appeared:
		return

	held_item_appeared = true
	held_item.play("appear")


func _play_held_item_put_away() -> void:
	if !held_item_appeared:
		return

	held_item_appeared = false
	held_item.play("put_away")
