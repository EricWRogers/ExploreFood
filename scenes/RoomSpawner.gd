extends CSGBox3D
@onready var thing = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene = load("res://Player.tscn")
	var player = scene.instance()
	add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
