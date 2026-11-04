extends Control

var unlocked_recipes: Array[Node3D] #holds all unlocked recipes
var selected_foods: Array[Node3D] #hold what you select for the day
@export var MenuLimit = 3 #max allowed selected_foods

var ingredient_parent: Node
	
func _ready() -> void:
	pass
	#var scene = load("res://scenes/ui/food_menu_scroll_items.tscn")
	#var menu_item = scene.instance()
	#add_child(menu_item)
	
#get unlocked reccipies and create a "food_menu_scroll_item" for it
func Create_foodMenu_items():
	pass
