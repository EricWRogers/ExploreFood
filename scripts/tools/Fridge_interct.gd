extends Node3D

@export var ing : BaseFood :
	set(value):
		ing = value
		ing.node = self
		$Sprite2d.texture = value.icon #change to account for 3d

#setter varuble to controle the visibillity of the lable
var enabled : bool = false:
	set(value):
		enabled = value
		$Label.visible = value 
		
func _ready():
	enabled = false
	#name = ing.title #update name with item title

func _input(event):
	#check if enabled and if key pressed
	if event is InputEventKey and event.is_pressed() and enabled:
		if event.keycode == KEY_E:
			print(name + "Activated.") #testing 
#			if item: #interact will activate item
#				item.activated()

func _on_area_3d_body_entered(body: Node3D) -> void:
	enabled = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	enabled = false
	if ing:  #exiting body will deactivate item
		ing.de_activate()
