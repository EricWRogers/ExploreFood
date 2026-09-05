extends StaticBody3D

var bagels = []
var amount_of_bagels_stored = 0

var counter = [null, null, null, null, null, null, null, null, null, null, null, null]

@onready var mesh_instance_3d: MeshInstance3D = $BagelCounter
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

func add_to_counter(item):
	for i in range(counter.size()):
		if counter[i] == null:
			counter[i] = item
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
