extends MarginContainer

@export var ui_label: Label
@export var ui_icon: TextureRect
@export var ui_button: Button
@export var ui_station: TextureRect
@export var ui_flow: FlowContainer
@export var ui_recipe: Recipe
signal node_selected
signal node_toggled(toggled_on: bool, ui_recipe: Recipe)

func _ready() -> void:
	pass

func _on_button_pressed() -> void:
	node_selected.emit()


func _on_button_toggled(toggled_on: bool) -> void:
	node_toggled.emit(toggled_on, ui_recipe)
