

extends HBoxContainer

@export var hotbar_slots: Array[VBoxContainer] = []
@export var max_slots := 6
@export var wrap_around := true
@export var scroll_cooldown := 0.04
signal update_held

var current_slot := 0
var scroll_timer := 0.0
var move_scroll := false

func _ready() -> void:
	InputManager.hotbar_icons = self
	update_control_scheme()

func update_control_scheme():
	if Manager.current_control_device == "controller":
		%WSKeyboard.hide()
		%ScrollWheel.hide()
		%ADKeyBoard.hide()
		if move_scroll:
			$"../../MarginContainer2/StationSlots".show()
			%HorizStick.show()
			%VertStick.show()
			%Shoulders.hide()
		else:
			%HorizStick.hide()
			%VertStick.hide()
			%Shoulders.show()
	elif Manager.current_control_device == "keyboardmouse":
		%HorizStick.hide()
		%VertStick.hide()
		%Shoulders.hide()
		if move_scroll:
			$"../../MarginContainer2/StationSlots".show()
			%WSKeyboard.show()
			%ADKeyBoard.show()
			%ScrollWheel.hide()
		else:
			%ScrollWheel.show()
			%WSKeyboard.hide()
			%ADKeyBoard.hide()

func _process(delta: float) -> void:
	if scroll_timer > 0.0:
		scroll_timer -= delta
func _input(event: InputEvent) -> void:
	if $"../../..".in_station and $"../../..".get_held_item() != null:
		$"../../..".get_held_item().hide()
	if $"../../..".in_station:
		move_scroll = true
		update_control_scheme()
	else:
		move_scroll = false
		update_control_scheme()
	if event is InputEventKey and event.pressed and not event.echo:
		var number = event.keycode - KEY_0
		if number >= 1 and number <= max_slots:
			var selected_slot = number - 1
			if selected_slot == current_slot:
				for item in hotbar_slots:
					item._unfocus()
				current_slot = -1
				emit_signal("update_held", -1)
				Manager.player_current_hovered_slot = -1
			else:
				current_slot = selected_slot
				current_slot = clampi(current_slot, 0, hotbar_slots.size() - 1)
				for item in hotbar_slots:
					item._unfocus()
				hotbar_slots[current_slot]._focus()
				emit_signal("update_held", current_slot)
				Manager.player_current_hovered_slot = current_slot
				%Controls.reparent(hotbar_slots[current_slot].control_box, false)
			return
	var direction := 0
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if scroll_timer > 0.0:
				return
			direction = -1
			scroll_timer = scroll_cooldown
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if scroll_timer > 0.0:
				return
			direction = 1
			scroll_timer = scroll_cooldown
	elif event is InputEventKey and event.pressed and move_scroll:
		if event.physical_keycode == KEY_A:
			if scroll_timer > 0.0:
				return
			direction = -1
			scroll_timer = scroll_cooldown
		elif event.physical_keycode == KEY_D:
			if scroll_timer > 0.0:
				return
			direction = 1
			scroll_timer = scroll_cooldown
		if event.physical_keycode == KEY_W:
			if scroll_timer > 0.0:
				return
			request_insert(true)
			scroll_timer = scroll_cooldown
		elif event.physical_keycode == KEY_S:
			if scroll_timer > 0.0:
				return
			request_insert(false)
			scroll_timer = scroll_cooldown
	elif event is InputEventJoypadMotion and move_scroll:
		var threshold := 0.5
		
		if event.axis == JOY_AXIS_LEFT_X:
			if event.axis_value < -threshold:
				if scroll_timer <= 0.0:
					direction = -1
					scroll_timer = scroll_cooldown + 0.06
			elif event.axis_value > threshold:
				if scroll_timer <= 0.0:
					direction = 1
					scroll_timer = scroll_cooldown + 0.06
		
		if event.axis == JOY_AXIS_LEFT_Y:
			if event.axis_value < -threshold:
				if scroll_timer <= 0.0:
					request_insert(true)
					scroll_timer = scroll_cooldown + 0.1
			elif event.axis_value > threshold:
				if scroll_timer <= 0.0:
					request_insert(false)
					scroll_timer = scroll_cooldown + 0.1
	else:
		if event.is_action_pressed("inventory_left_zoom_in", false, true):
			direction = -1
		elif event.is_action_pressed("inventory_right_zoom_out", false, true):
			direction = 1
	if direction == 0:
		return
	current_slot += direction
	if wrap_around:
		current_slot = (current_slot + max_slots) % max_slots
	else:
		current_slot = clampi(current_slot, 0, max_slots - 1)
	
	current_slot = clampi(current_slot, 0, mini(max_slots, hotbar_slots.size()) - 1)
	for item in hotbar_slots:
		item._unfocus()
	hotbar_slots[current_slot]._focus()
	emit_signal("update_held", current_slot)
	Manager.player_current_hovered_slot = current_slot
	%Controls.reparent(hotbar_slots[current_slot].control_box, false)
func _update_visual(tie):
	var viewers = get_tree().get_nodes_in_group("Viewer")
	for item in viewers:
		if item.slot_tie == tie:
			var slot = hotbar_slots[item.slot_tie]
			slot.update_texture(item.subviewport)
			print("putting subviewport texture into hotbar")
			break
func select_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= mini(max_slots, hotbar_slots.size()):
		return

	current_slot = slot_index

	for item in hotbar_slots:
		item._unfocus()

	hotbar_slots[current_slot]._focus()
	emit_signal("update_held", current_slot)
	Manager.player_current_hovered_slot = current_slot
	#await get_tree().process_frame
	%Controls.reparent(hotbar_slots[current_slot].control_box, false)
func set_eligibility(index, eligibility):
	if index >= 0 and index < hotbar_slots.size():
		hotbar_slots[index].eligibility = eligibility
		hotbar_slots[index].update_eligible()

func request_insert(inout):
	#print(current_slot)
	if current_slot > -1 and move_scroll and $"../../..".get_held_item() != null:
		var offset_target = current_slot
		print("insert: current_slot=", current_slot, " move_scroll=", move_scroll, " held=", $"../../..".get_held_item())
		if inout:
			var tween = create_tween()
			if hotbar_slots[offset_target].eligibility == "valid":
				if !hotbar_slots[offset_target].requested_select:
					hotbar_slots[offset_target].requested_select = true
					tween.set_parallel(true)
					tween.tween_property(hotbar_slots[offset_target].texture, "offset_transform_position:y", -40, 0.2)
					tween.tween_property(hotbar_slots[offset_target].texture, "self_modulate", Color(1.0, 1.0, 1.0, 0.6), 0.2)
					$"../../MarginContainer2/StationSlots".slots.append(hotbar_slots[offset_target].texture.get_texture())
					$"../../MarginContainer2/StationSlots".update_slots()
			if hotbar_slots[offset_target].eligibility == "invalid":
				tween.tween_property(hotbar_slots[offset_target].texture, "offset_transform_position:x", -10, 0.06)
				tween.tween_property(hotbar_slots[offset_target].texture, "offset_transform_position:x", 4, 0.04)
				tween.tween_property(hotbar_slots[offset_target].texture, "offset_transform_position:x", -2, 0.02)
				tween.tween_property(hotbar_slots[offset_target].texture, "offset_transform_position:x", 0, 0.01)
		else:
			var tween = create_tween()
			tween.set_parallel(true)
			hotbar_slots[offset_target].requested_select = false
			tween.tween_property(hotbar_slots[offset_target].texture, "offset_transform_position:y", 0, 0.2)
			tween.tween_property(hotbar_slots[offset_target].texture, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
			if hotbar_slots[offset_target].texture.texture in $"../../MarginContainer2/StationSlots".slots:
				$"../../MarginContainer2/StationSlots".slots.erase(hotbar_slots[offset_target].texture.get_texture())
				$"../../MarginContainer2/StationSlots".update_slots()
func rip_away_reset():
	$"../../MarginContainer2/StationSlots".hide()
	for slot in hotbar_slots:
		var tween = create_tween()
		tween.tween_property(slot.texture, "offset_transform_position:y", 0, 0.2)
