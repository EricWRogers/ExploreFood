extends Node3D

#collect 10 fragments to make a waypoint
var needed_amount = 10
var current_amount 

#collect waypoint fragment
func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		current_amount += 1
		print(current_amount)
		if current_amount >=10:
			current_amount == 0
			#create full waypoint
