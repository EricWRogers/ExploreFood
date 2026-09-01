extends SubViewport

var snap_interval = 0.22
var snap_frame = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("create_icon"):
		$Timer.start()
		begin_snapshot()

func begin_snapshot():
	$KillerBeanSproject2/AnimationPlayer.play("Run")
	for i in range(15):
		await RenderingServer.frame_post_draw
		var texture = get_texture()
		var image = texture.get_image()
		var err = image.save_png("res://Prefabs/UI/loading_frames/output_icon_" + str(snap_frame) + ".png")
		snap_frame += 1
		if err == OK:
			print("Icon saved successfully!")
		else:
			print("Failed to save icon, error code: ", err)
		await get_tree().create_timer(snap_interval).timeout


func _on_timer_timeout() -> void:
	get_tree().quit()
