extends Node

#var current_device : String

const KEYBOARD_PROMPTS = {
	"interact": "res://fp_scenes/inputs/mouse_keyboard/keyboard_e.png",
	"jump": "res://Assets/UI/ButtonPrompts/KeyboardMouse/Space.png"
}

const PLAYSTATION_PROMPTS = {
	"interact": "res://fp_scenes/inputs/playstation/playstation_button_circle.png",
	"jump": "res://Assets/UI/ButtonPrompts/Xbox/A.png"
}
const SWITCH_PROMPTS = {
	"interact": "res://fp_scenes/inputs/switch/switch_button_a.png",
	"jump": "res://Assets/UI/ButtonPrompts/Xbox/A.png"
}
const XBOX_PROMPTS = {
	"interact": "res://fp_scenes/inputs/xbox/xbox_button_b.png",
	"jump": "res://Assets/UI/ButtonPrompts/Xbox/A.png"
}
func get_prompt(action: String) -> Texture2D:
	var prompts = KEYBOARD_PROMPTS

	if Manager.current_control_device == "controller":
		prompts = SWITCH_PROMPTS

	if not prompts.has(action):
		return null

	return load(prompts[action]) as Texture2D
