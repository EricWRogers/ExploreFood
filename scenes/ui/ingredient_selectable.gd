extends MarginContainer
@onready var icon: TextureRect = $Icon


var icon_show : Texture2D
var name_of: String
var flavor: String
var family: String
var desc: String
var location: String
var screenshot: Texture2D
var book_owner
var type : String = "Ingredient"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_icon()

func display_icon():
	if icon_show:
		icon.texture = icon_show
func display_information():
	pass
func become_active():
	icon.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	book_owner.set_information(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
