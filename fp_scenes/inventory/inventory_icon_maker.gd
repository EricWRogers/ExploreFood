extends Node3D

@onready var subviewport: SubViewport = $SubViewport
@onready var spawn_pivot: Node3D = $SubViewport/Pivot
var slot_tie : int
var item : RigidBody3D
func _set_FOV(amnt):
	$SubViewport/Camera3D.fov = amnt
func spawn_item(original):
	var new_object = original.duplicate()
	new_object.freeze = true
	new_object.linear_velocity = Vector3.ZERO
	new_object.angular_velocity = Vector3.ZERO

	spawn_pivot.add_child(new_object)
	$SubViewport/Camera3D.fov = new_object.inventory_icon_FOV
	item = new_object
	new_object.position = Vector3.ZERO
	new_object.rotation = Vector3.ZERO
func reset_item():
	item = null
	for child in spawn_pivot.get_children():
		child.queue_free()
