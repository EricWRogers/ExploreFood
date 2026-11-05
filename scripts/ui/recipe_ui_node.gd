extends MarginContainer

@export var ui_label: Label
@export var ui_icon: TextureRect
@export var ui_button: Button

signal node_selected
signal node_toggled

func _ready() -> void:
	pass

func _on_button_pressed() -> void:
	node_selected.emit()


func _on_button_toggled(toggled_on: bool) -> void:
	node_toggled.emit(toggled_on)
