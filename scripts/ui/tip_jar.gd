extends StaticBody3D

@onready var label_3d: Label3D = $Label3D
var player_money = 0 #im guessing this will probably go into an autoloader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.text = str("TIPS: ", player_money)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("absorb"):
		if body.type == "coin":
			player_money += 1
			label_3d.text = str("TIPS: ", player_money)
			body.absorb()
