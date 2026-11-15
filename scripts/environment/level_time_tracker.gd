extends Node3D

signal day_finished

@export var world_environment: WorldEnvironment
@export var directional_light: DirectionalLight3D

@export var day_length: float = 180.0

func _ready() -> void:
	start_day()

func _process(delta: float) -> void:
	print(world_environment.environment.adjustment_brightness)
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
	
	# Emit halfway through
	#tween.tween_interval(90.0)
	#tween.tween_callback(func(): day_finished.emit())
	
	tween.finished.connect(_on_day_finished)

func _on_day_finished() -> void:
	day_finished.emit()
