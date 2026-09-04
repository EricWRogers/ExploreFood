extends Node3D

const BAGEL_SPREAD_PIECE = preload("uid://bg30cyd7f3v1o")
const BAGEL_TOP = preload("uid://d13rs5g0a2u0r")

var current_top

func _ready() -> void:
	current_top = self.global_position

func add_spread(color):
	var bagel_spread = BAGEL_SPREAD_PIECE.instantiate()
	add_child(bagel_spread)
	bagel_spread.global_position = current_top
	bagel_spread.change_color(color)
	current_top.y += 0.076
	print(str("current_top", current_top))
	
func add_top():
	var bagel_top = BAGEL_TOP.instantiate()
	add_child(bagel_top)
	bagel_top.global_position = current_top
	show()
