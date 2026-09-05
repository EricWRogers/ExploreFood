extends StaticBody3D

var bagels = []
var amount_of_bagels_stored = 0

var counter = [null, null, null, null, null, null, null, null, null, null, null, null]

@onready var mesh_instance_3d: MeshInstance3D = $BagelCounter
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

func add_to_counter(item):
	if not Manager.currently_held_bagel:
		return
	for i in range(counter.size()):
		if counter[i] == null:
			counter[i] = item
			
			var marker = get_node("Marker3D" + str(i + 1))
			if Manager.currently_held_bagel:
				Manager.clear_current_bagel()
				Manager.currently_held_bagel.held = false
				Manager.currently_held_bagel.in_sale = true
				Manager.currently_held_bagel.global_position = marker.global_position
				Manager.currently_held_bagel.global_position.y += 0.13
				Manager.currently_held_bagel.global_rotation = marker.global_rotation
				Manager.currently_held_bagel.rotation_degrees.x += 180
				Manager.currently_held_bagel.freeze = true
				Manager.currently_held_bagel = null
				
			print("Placed item in slot ", i)
			return true
	
	print("Counter is full!")
	return false
	
func remove_first_item():
	for i in range(counter.size()):
		if counter[i] != null:
			counter[i] = null
			return
			
func on_looked_at():
	overlay.set_shader_parameter("transparency", 0.1)
	$Node3D.show()
	
func on_looked_away():
	overlay.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()
