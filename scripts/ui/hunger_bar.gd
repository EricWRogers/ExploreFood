extends ProgressBar

func _ready() -> void:
	pass

func set_hunger(new_value: float) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "value", new_value, .5)
	tween.tween_property($"../TextureProgressBar3", "value", new_value, .5)
	tween.set_parallel(false)
	tween.tween_callback(check_dead)
	
func check_dead():
	if $"../../../../../..".hunger == 0:
		$"../../../../../..".death()

func _on_value_changed(value: float) -> void:
	var ratio = (value - min_value) / (max_value - min_value)
	var fill_size = Vector2(size.x * ratio, size.y)
	var middle = fill_size.x / 2
	print(middle)
	$"../../../../../MarginContainer5".global_position.x = middle + 20
	material.set_shader_parameter("node_size", fill_size)
	print($"../../../../../MarginContainer5".position)
