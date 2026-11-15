extends Node3D

signal day_finished

@export var world_environment: WorldEnvironment
@export var directional_light: DirectionalLight3D
@export var day_length: float = 300.0

@onready var label: Label = $Control/Label

var time_progress: float = 0.0

func _ready() -> void:
	label.text = "06:00"
	start_day()

func start_day() -> void:
	var tween = create_tween()

	tween.set_parallel(true)

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)


	tween.tween_property(
		world_environment.environment,
		"adjustment_brightness",
		0.3,
		day_length
	)


	tween.tween_property(
		directional_light,
		"light_energy",
		0.0,
		day_length
	)
	
	var clock_tween = create_tween()


	clock_tween.tween_method(
		update_time,
		0.0,
		1.0,
		day_length
	)

	tween.finished.connect(_on_day_finished)

func update_time(progress: float) -> void:

	var total_minutes = int(360 + (progress * 1200))

	total_minutes = (total_minutes / 10) * 10
	var hours = (total_minutes / 60) % 24
	var minutes = total_minutes % 60
	label.text = "%02d:%02d" % [hours, minutes]

func _on_day_finished() -> void:
	label.text = "02:00"
	day_finished.emit()
