extends Control

#@onready var holder: Control = $Holder
@export var holder: Control

var paused : bool = false;


func _input(event):
	if event.is_action_pressed("Exit") and Manager.player.can_pause:
		if paused:
			unpause()
		else:
			pause()


func _ready() -> void:
	if (holder == null):
		printerr("ERROR: Pause Menu cannot find UI children!")
		return
	
	print("holder detected.")
	holder.visible = false


func pause():
	if holder == null:
		return
	
	print("pause!")
	paused = !paused
	get_tree().paused = true
	holder.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func unpause():
	if holder == null:
		return
	
	print("unpause!")
	paused = !paused
	get_tree().paused = false
	holder.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_pressed() -> void:
	unpause()


func _on_exit_pressed() -> void:
	get_tree().quit()
