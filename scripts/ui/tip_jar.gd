extends StaticBody3D

@onready var label_3d: Label3D = $Label3D
 #im guessing this will probably go into an autoloader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.text = str("TIPS: ", Manager.money)

func _process(delta: float) -> void:
	label_3d.text = str("TIPS: ", Manager.money)
