extends CharacterBody3D

const STATION_GROUP := "Station"

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

var can_move := true
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
var station_candidates := []
var station_focus: StaticBody3D
var current_taken_slots := 0
var inventory: Array = [null, null, null, null, null, null]
var total_viewers := 1
var held_item_appeared := false
var is_holding := false
var in_station := false
var special_pickup := false
var menu_open := false
var current_station : StaticBody3D
@export var current_recipe : Resource
const GRAB_GROUPS := ["Ingredient", "Item"]


@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %Doremi
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var shadow: SpringArm3D = $Shadow
@onready var decal: Decal = $Shadow/Decal
@onready var inventory_viewer = preload("res://fp_scenes/inventory/inventory_icon_maker.tscn")
@onready var ingredient_texture = preload("res://scenes/ui/Diner/recipe_ingredient_flow.tscn")
@onready var food_hold_pnt: Marker3D = $Doremi/Skeleton3D/ItemAttachment/FoodHoldPnt
@onready var held_item: AnimationPlayer = $HeldItem

#Sound Effects
@onready var jumpSFX: AudioStreamPlayer = $Jump
#@onready var idle_sfx: AudioStreamPlayer = $IdleSFX
#@onready var sprintSFX: AudioStreamPlayer = $Sprint


func _ready() -> void:
	#confirm_button.pressed.connect(confirm_recipes)
	CameraManager.player_cam = $CameraPivot/SpringArm3D/PlayerCam
	CameraManager.collect_cam = $Doremi/CollectCamPivot/CollectCam
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_gravity_retain = _gravity
	max_spring_length = shadow.spring_length
	_restore_inventory.call_deferred()

func _restore_inventory() -> void:
	var saved: Array = Manager.inventory.duplicate()
	var saved_slot: int = Manager.player_current_hovered_slot

	for view in get_tree().get_nodes_in_group("Viewer"):
		if view.slot_tie >= saved.size() or saved[view.slot_tie] == null:
			view.reset_item()

	for i in saved.size():
		var entry = saved[i]
		var path := ""
		if entry is String:
			path = entry
		elif entry is Object and is_instance_valid(entry):
			path = entry.scene_file_path
		if path == "":
			continue
		var thingy = load(path).instantiate()
		get_tree().current_scene.add_child(thingy)
		pickup_item(thingy, i)

	if saved_slot >= 0:
		$CanvasLayer/MarginContainer/Hotbar.select_slot(saved_slot)

func _sync_manager_inventory() -> void:
	var saved: Array = []
	for item in inventory:
		if item != null and is_instance_valid(item):
			saved.append(item.scene_file_path)
		else:
			saved.append(null)
	Manager.inventory = saved

	
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
func reset_hotbar_eligibility():
	for i in inventory.size():
		$CanvasLayer/MarginContainer/Hotbar.set_eligibility(i, "reset")
func update_hotbar_eligibility():
	print("updating")
	for i in inventory.size():
		var state := "none"
		if station_focus != null:
			state = station_focus.get_eligibility(inventory[i])
		$CanvasLayer/MarginContainer/Hotbar.set_eligibility(i, state)
## freeze no movement when ledged
func freeze_velocity():
	velocity = Vector3.ZERO
func _process(_delta: float) -> void:
	if special_pickup:
		return
	if not can_move and current_station:
		if Input.is_action_pressed("Interact") and current_station.valid_dish:
			$CanvasLayer/MarginContainer3/Panel/TextureProgressBar.value += 0.8
		else:
			$CanvasLayer/MarginContainer3/Panel/TextureProgressBar.value -= 0.2
		velocity = Vector3.ZERO
		move_and_slide()
		return
	elif not can_move:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	if Input.is_action_just_pressed("dropthrow") and Manager.player_current_hovered_slot != -1:
		dropthrow()
	var new_scale: float = shadow.get_hit_length()
	new_scale = 1.0 - (new_scale / max_spring_length)
	new_scale = clamp(new_scale, 0.0, 1.0)
	decal.size = Vector3(new_scale, 1.0, new_scale)
	var closest_station: Node3D = null
	var closest_station_distance: float = INF
	for station in station_candidates:
		var d = global_position.distance_to(station.global_position)
		if d < closest_station_distance:
			closest_station_distance = d
			closest_station = station

	unfocus_all_stations()
	station_focus = closest_station
	if station_focus != null:
		station_focus._focus_obtain()
	if Input.is_action_just_pressed("cook") and station_focus != null:
		start_station()
		current_station = station_focus
		#current_station.player = self
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
		pickup_item(grab_focus, Manager.player_current_hovered_slot)
func get_held_item() -> RigidBody3D:
	var slot: int = Manager.player_current_hovered_slot
	if slot < 0 or slot >= inventory.size():
		return null
	return inventory[slot]
		
func unfocus_all_stations():
	for station in get_tree().get_nodes_in_group(STATION_GROUP):
		station._defocus()
		
func start_station() -> void:
	if station_focus == null:
		return
	if not station_focus.has_method("_start_station"):
		push_warning("%s has no _start_station()" % station_focus.name)
		return
	station_focus._start_station(self)

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
						_sync_manager_inventory()
						for view in viewer_family:
							if view.slot_tie == inv_ndx:
								view.reset_item()
					#print(inventory)
					break
func pickup_item(item: RigidBody3D, preferred_slot: int = -1) -> bool:
	var target_slot := preferred_slot
	if target_slot < 0 or target_slot >= inventory.size() or inventory[target_slot] != null:
		target_slot = inventory.find(null)  # first empty slot, -1 if full
	if target_slot == -1:
		return false

	inventory[target_slot] = item
	_sync_manager_inventory()

	$CanvasLayer/MarginContainer/Hotbar.select_slot(target_slot)
	item._held_slot = target_slot
	item._become_held(food_hold_pnt)

	for stored in inventory:
		if stored != null:
			stored._become_stored()

	if !in_station:
		item._become_visibly_held()
	%Doremi.is_holding = true
	is_holding = true
	if is_on_floor():
		held_item_appeared = false
	_play_held_item_appear()

	item.global_position = food_hold_pnt.global_position
	current_taken_slots += 1
	_on_item_picked_up(item, target_slot)
	spawn_inventory_slot_viewer(item, target_slot)
	return true
func delete_slot(slot: int) -> void:
	if slot < 0 or slot >= inventory.size():
		return
	var item = inventory[slot]
	if item == null:
		return

	%Doremi.is_holding = false
	is_holding = false
	current_taken_slots -= 1
	_on_item_dropped(item)

	inventory[slot] = null
	_sync_manager_inventory()

	for view in get_tree().get_nodes_in_group("Viewer"):
		if view.slot_tie == slot:
			view.reset_item()

	grab_candidates.erase(item)
	if grab_focus == item:
		grab_focus = null

	_play_held_item_put_away()
	item.queue_free()
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
	if special_pickup:
		velocity = Vector3.ZERO
		return
	if not can_move:
		velocity = Vector3.ZERO
		move_and_slide()
		return
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
		jumpSFX.play()

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
				#sprintSFX.play()
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
		#idle_sfx.play()
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
	if body.is_in_group(STATION_GROUP) and not station_candidates.has(body):
		station_candidates.append(body)

func _on_item_detect_body_exited(body: Node3D) -> void:
	grab_candidates.erase(body)
	station_candidates.erase(body)
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
		if !in_station:
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
	if in_station:
		return
	if held_item_appeared:
		return

	held_item_appeared = true
	held_item.play("appear")


func _play_held_item_put_away() -> void:
	if !held_item_appeared:
		return

	held_item_appeared = false
	held_item.play("put_away")
func display_cook_button(show):
	if show:
		$CanvasLayer/MarginContainer3.show()
	else:
		$CanvasLayer/MarginContainer3.hide()
func queue_food_in_oven():
	for item in $CanvasLayer/MarginContainer/Hotbar.to_be_deleted:
		delete_slot(item)

func _on_texture_progress_bar_value_changed(value: float) -> void:
	if value >= 100.0:
		queue_food_in_oven()
		value = 0
		display_cook_button(false)
		current_station.start_cooking_time()
		current_station.rip_away()

func pickup_special() -> void:
	if special_pickup:
		return
	CameraManager.switch_to_collect()
	special_pickup = true
	velocity = Vector3.ZERO
	not_moving = false
	$IdleBreak.stop()
	$Cliff.stop()
	balancing_cliff_edge = false
	breaking_idle = false
	_play_held_item_put_away()
	_skin.pickup_spec()
	$CollectSpec.start()

func set_2_recipes():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/StoveChoice.show()
	var index = 0
	for recipe in Manager.player_selected_recipes:
		var current_recipe_node: Node
		current_recipe_node = $CanvasLayer/StoveChoice/VBoxContainer/HBoxContainer.get_child(index)
		
		# set recipe data #
		current_recipe_node.ui_recipe = recipe
		current_recipe_node.ui_label.text = recipe.recipe_name
		current_recipe_node.ui_icon.texture = recipe.recipe_icon
		current_recipe_node.ui_station.texture = recipe.recipe_station_tex
		for item in recipe.recipe_ingredients:
			var ingredient_tex = ingredient_texture.instantiate()
			current_recipe_node.ui_flow.add_child(ingredient_tex)
			var item_pull = item.instantiate()
			if item_pull.icon != null:
				ingredient_tex.texture = item_pull.icon
		index += 1
		


func _on_collect_spec_timeout() -> void:
	special_pickup = false
	CameraManager.switch_to_regular()
	_skin.put_away_recipe()



func _on_food1_pressed() -> void:
	$CanvasLayer/StoveChoice.hide()
	current_station.selected_recipe = true
	var picked = Manager.player_selected_recipes[0]
	current_station.to_be_made = picked.product
	current_station.recipe.assign(picked.recipe_ingredients)
	current_station._start_station(self)


func _on_food2_pressed() -> void:
	$CanvasLayer/StoveChoice.hide()
	current_station.selected_recipe = true
	var picked = Manager.player_selected_recipes[1]
	current_station.to_be_made = picked.product
	current_station.recipe.assign(picked.recipe_ingredients)
	current_station._start_station(self)
