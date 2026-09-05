extends SubViewport

func _process(delta: float) -> void:
	print("pressed something")
	if Input.is_action_just_pressed("create_icon"):
		print("pressed O")
		save_icon()

func save_icon() -> void:
	await RenderingServer.frame_post_draw
	print("Active camera for this viewport: ", get_camera_3d())
	var texture = get_texture()
	var image = texture.get_image()
	var err = image.save_png("res://assets/ui/item_icons/output_icon.png")
	if err == OK:
		print("Icon saved successfully!")
	else:
		print("Failed to save icon, error code: ", err)

	
