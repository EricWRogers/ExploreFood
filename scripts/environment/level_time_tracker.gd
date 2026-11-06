extends Node3D

const new_level_path = "res://scenes/levels/diner_hub.tscn"
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $Control/Label
@export var level_time : float = 60
@export var add_time : float = 5.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = level_time
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/Label.text = "Time: " + ("%.2f" % timer.time_left)


func _on_timer_timeout() -> void:
	Manager.level_manager.call_deferred("change_scene", new_level_path, self.get_owner(), Manager.level_manager.change_mode.DELETE)


var label_tween: Tween

func _on_portal_food_entered() -> void:
	timer.start(timer.time_left + add_time)

	if label_tween and label_tween.is_running():
		label_tween.kill()

	timer_label.scale = Vector2(1.0, 1.0)

	label_tween = create_tween()
	label_tween.tween_property(timer_label, "scale", Vector2(1.4, 1.4), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	label_tween.tween_property(timer_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
