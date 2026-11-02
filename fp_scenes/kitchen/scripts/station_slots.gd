extends HBoxContainer

@export var hotbar_slots: Array[TextureRect] = []
var slots := [] 
var size_check : int

func update_slots():
	for item in hotbar_slots:
			item.texture = null
	for i in slots.size():
		if slots.size() <= hotbar_slots.size():
			hotbar_slots[i].texture = slots[i]
		
