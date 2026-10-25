

extends HBoxContainer

@export var hotbar_slots: Array[VBoxContainer] = []
@export var max_slots := 6
@export var wrap_around := true
@export var scroll_cooldown := 0.04

var current_slot := 0
var scroll_timer := 0.0

func _process(delta: float) -> void:
	if scroll_timer > 0.0:
		scroll_timer -= delta
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var number = event.keycode - KEY_0

		if number >= 1 and number <= max_slots:
			print(number)
			current_slot = number - 1
			current_slot = clampi(current_slot, 0, hotbar_slots.size())
			for item in hotbar_slots:
				item._unfocus()
			hotbar_slots[current_slot]._focus()
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
	else:
		if Input.is_action_just_pressed("inventory_left_zoom_in"):
			direction = -1
		elif Input.is_action_just_pressed("inventory_right_zoom_out"):
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
	Manager.player_current_hovered_slot = current_slot
func _update_visual(tie):
	var viewers = get_tree().get_nodes_in_group("Viewer")
	for item in viewers:
		if item.slot_tie == tie:
			var slot = hotbar_slots[item.slot_tie]
			slot.update_texture(item.subviewport)
			print("putting subviewport texture into hotbar")
			break
	
