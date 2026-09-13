extends Node3D

@export var title : String
@export var cost : int
var total_put_in = 0
var bar_value

signal purchased

@onready var cost_label: Label3D = $Cost
@onready var title_label: Label3D = $Title
@onready var texture_progress_bar: ProgressBar = $SubViewport/TextureProgressBar

func _ready() -> void:
	title_label.text = title
	cost_label.text = str("$",total_put_in,"/","$",cost)

func update_total():
	bar_value = (total_put_in / cost) * 100.0
	texture_progress_bar.value = bar_value
	cost_label.text = str("$",total_put_in,"/","$",cost)
