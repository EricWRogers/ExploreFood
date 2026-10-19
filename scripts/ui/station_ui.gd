extends Control

@export var icons: Array[TextureRect] = []
var filled := 0

func _update_visual(texture):
	print(icons[filled])
	icons[filled].texture = texture
	filled += 1
func _reset_visual():
	filled = 0
	for icon in icons:
		icon.texture = null
