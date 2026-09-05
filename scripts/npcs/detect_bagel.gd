extends StaticBody3D

var my_bagel
var bagel_value
func bagel_detect():
	if $"..".hands_full == false:
		pass
		
func selected_something():
	self.set_collision_layer_value(11, false)
	$"..".hands_full = true
func carry_bagel():
	$"..".holding()
	$"../Timer".start()
	Manager.money += bagel_value
	Manager.player.update_cash()
func _process(delta: float) -> void:
	if my_bagel:
		my_bagel.global_position = $"../Marker3D".global_position
		my_bagel.global_rotation = Vector3(0,0,0)


func _on_timer_timeout() -> void:
	my_bagel.queue_free()
	$"..".walking()
