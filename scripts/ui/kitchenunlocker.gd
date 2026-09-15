extends Node3D



func _on_money_sign_3_purchased() -> void:
	$"../Tutorial_Counter_Kitchen".showwaffle()
	Manager.waffledimension = true
