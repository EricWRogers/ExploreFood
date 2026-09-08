extends StaticBody3D

var bagels = []
var amount_of_bagels_stored = 0

var counter = [null, null, null, null, null, null, null, null, null, null, null, null]

@onready var mesh_instance_3d: MeshInstance3D = $BagelCounter
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

func add_to_counter(item): #item is never used. Probably safe to remove -Nate
	return
	var held_bagel_reference = null
	if not Manager.currently_held_bagel:
		return
	for i in range(counter.size()):
		if counter[i] == null:
			counter[i] = Manager.currently_held_bagel
			
			var marker = get_node("Marker3D" + str(i + 1))
			if Manager.currently_held_bagel:
				held_bagel_reference = Manager.currently_held_bagel
				Manager.clear_current_bagel()
				held_bagel_reference.held = false
				held_bagel_reference.in_sale = true
				held_bagel_reference.global_position = marker.global_position
				held_bagel_reference.global_position.y += 0.13
				held_bagel_reference.global_rotation = marker.global_rotation
				held_bagel_reference.rotation_degrees.x += 180
				held_bagel_reference.freeze = true
				Manager.currently_held_bagel = null
				
			print("Placed item in slot ", i)
			return true
	
	print("Counter is full!")
	return false
	
func remove_first_item():
	var empty = true
	var return_var = null
	for i in range(counter.size()):
		if counter[i] != null:
			empty = false
			return_var = counter[i]
			counter[i] = null
			return return_var
	if empty == true:
		return null
	
func on_looked_at():
	return
	overlay.set_shader_parameter("transparency", 0.1)
	$InteractUI.show()
	
func on_looked_away():
	return
	overlay.set_shader_parameter("transparency", 0.0)
	$InteractUI.hide()


func _on_bagel_detect_body_entered(body: Node3D) -> void:
	if body.has_method("bagel_detect"):
		var item = remove_first_item()
		if item == null:
			pass
			#body.case_empty()
			#print("empty")
		else:
			body.selected_something()
			body.my_bagel = item
			body.bagel_value = item.price
			body.carry_bagel()
			print(item)
			
