extends VBoxContainer

@export var panel_shrink : Panel
@export var panel_modulate : Panel
@export var texture : TextureRect
var eligibility : String

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(panel_modulate, "modulate", Color("bdbdbdff"), 0.05)

func _focus():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel_shrink, "scale", Vector2(0.805, 0.805), 0.05)
	tween.tween_property(panel_modulate, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.05)

func _unfocus():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel_shrink, "scale", Vector2(0.96, 0.96), 0.05)
	tween.tween_property(panel_modulate, "modulate", Color("bdbdbdff"), 0.05)

func update_texture(tex):
	texture.texture = tex.get_texture()
	
func update_eligible():
	var tween = create_tween()
	match eligibility:
		"valid":
			tween.tween_property(panel_modulate, "self_modulate", Color("00ff77ff"), 0.05)
		"invalid":
			tween.tween_property(panel_modulate, "self_modulate", Color("ff0000ff"), 0.05)
		"none":
			tween.tween_property(panel_modulate, "self_modulate", Color("5c5c5cff"), 0.05)
		"reset":
			tween.tween_property(panel_modulate, "self_modulate", Color("ffffffff"), 0.05)
	
