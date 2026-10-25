extends VBoxContainer

@export var panel_shrink : Panel
@export var texture : TextureRect

func _focus():
	var tween = create_tween()
	tween.tween_property(panel_shrink, "scale", Vector2(0.805, 0.805), 0.05)

func _unfocus():
	var tween = create_tween()
	tween.tween_property(panel_shrink, "scale", Vector2(0.96, 0.96), 0.05)

func update_texture(tex):
	texture.texture = tex.get_texture()
