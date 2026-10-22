extends Control

@export var icons: Array[TextureRect] = []
@export var capacity: int = 6
var filled := 0

func _update_visual(texture):
	#print(icons[filled])
	icons[filled].texture = texture
	filled += 1

func _reset_visual():
	#print("reseting...")
	filled = 0
	for icon in icons:
		icon.texture = null
