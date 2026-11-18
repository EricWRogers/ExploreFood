extends Node3D

#collect 10 fragments to make a waypoint
var needed_amount = 10
@export var current_amount_portal_frag = 0

#collect waypoint fragment
func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		current_amount_portal_frag += 1
		# delete fragment object
		print(current_amount_portal_frag)
		if current_amount_portal_frag >=10:
			current_amount_portal_frag == 0
			#create full waypoint
