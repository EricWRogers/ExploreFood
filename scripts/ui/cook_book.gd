extends CanvasLayer

@onready var name_of: Label = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Name
@onready var flavor: Label = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/MarginContainer2/HBoxContainer/Flavor
@onready var family: Label = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/MarginContainer2/HBoxContainer/Family
@onready var desc: Label = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Desc
@onready var location: Label = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Location
@onready var screenshot: TextureRect = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Panel/Screenshot

@export var icons : Array[Control]

var tab_set = 0


func _ready() -> void:
	Manager.recipe_book = self
	
func unlock_icons(matcher):
	for item in icons:
		if item.name == matcher:
			item.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	
func appear():
	$AnimationPlayer.play("Appear")
	
func disappear():
	$AnimationPlayer.play("Dissappear")

var items = {
	"ingredients": {
		"terry": {
			"icon": "res://assets/ui/cook_book/screenshots/TerryScreenshot.png",
			"name": "Man Eater Bird",
			"unlocked": false,
			"flavor": "Savory Flavor",
			"family": "Egg Family",
			"desc": "This bird is known to bite the heads off anything that comes near",
			"found": "Found at high altitudes"
		},
		"waffle": {
			"icon": "res://assets/ui/cook_book/screenshots/WaffleScreenshot.png",
			"name": "Waffle Pad",
			"unlocked": false,
			"flavor": "Sweet Flavor",
			"family": "Grain Family",
			"desc": "They start as balls of dough on river beds. The molten syrupy water fully cooks them by the time they reach the surface.",
			"found": "Found floating in rivers and ponds."
		},
		"butter": {
			"icon": "res://assets/ui/cook_book/screenshots/FrogScreenshot.png",
			"name": "Butter Frog",
			"unlocked": false,
			"flavor": "Creamy Flavor",
			"family": "Dairy Family",
			"desc": "These creatures are a rare sight to see. If they do not escape the rivers they spawn in quick enough they will melt away.",
			"found": "Found outside but near rivers and ponds. Usually on waffle lily pads."
		},
		"doughbaby": {
			"icon": "res://assets/ui/cook_book/screenshots/DoughBebehs.png",
			"name": "DoughDough",
			"unlocked": false,
			"flavor": "Hearty Flavor",
			"family": "Grain Family",
			"desc": "Dough Doughs love to dance around in groups. Once mature they do not taste any good at all.",
			"found": "Found in low altitudes plains."
		},
		"babytear": {
			"icon": "res://assets/ui/cook_book/screenshots/TearBebehSS.png",
			"name": "Willow Sap",
			"unlocked": false,
			"flavor": "Salty Flavor",
			"family": "Sauce Family",
			"desc": "Is it tears or tree sap? Regardless it makes for a delicious dipping sauce.",
			"found": "Secreted from Weeping Willows"
		},
		"meatball": {
			"icon": "res://assets/ui/cook_book/screenshots/MeatBallScreenshot.png",
			"name": "Joker Fruit",
			"unlocked": false,
			"flavor": "Umami Flavor",
			"family": "Meat Family",
			"desc": "This meat will explode if you approach too suddenly. It is unsure what animal meat it is. Is it plant-based?",
			"found": "Grows out of Joker Fronds when they bloom."
		},
		"chknandwaffles": {
			"icon": "res://assets/ui/cook_book/screenshots/TerryScreenshot.png",
			"name": "Chicken n Waffles",
			"unlocked": false,
			"flavor": "",
			"family": "",
			"desc": "A classic, popularized on a small planet known as earth.",
			"found": "1 Bird + 1 Waffle + 1 Butter",
		},
		"meatpocket": {
			"icon": "res://assets/ui/cook_book/screenshots/TerryScreenshot.png",
			"name": "Meat Pockets",
			"unlocked": false,
			"flavor": "",
			"family": "",
			"desc": "Each bite is a juicy explosion that reminds you of better days. However, The sauce is a little unnerving.",
			"found": "1 Dough + 1 Meat + 1 Sauce"
		},
	}
}

func set_info(info):
	if items["ingredients"][str(info)]["unlocked"] == false:
		$MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Panel/Screenshot/ColorRect.show()
		name_of.text = "Undiscovered"
		name_of.add_theme_color_override("font_color", Color("000000ff"))
		flavor.text = "Unknown"
		family.text = "Unknown"
		desc.text = ""
		location.text = items["ingredients"][str(info)]["found"]
	else:
		name_of.text = items["ingredients"][str(info)]["name"]
		match tab_set:
			0:
				name_of.add_theme_color_override("font_color", Color("36a17c"))
			1:
				name_of.add_theme_color_override("font_color", Color("a13535"))
		flavor.text = items["ingredients"][str(info)]["flavor"]
		family.text = items["ingredients"][str(info)]["family"]
		desc.text = items["ingredients"][str(info)]["desc"]
		location.text = items["ingredients"][str(info)]["found"]
		screenshot.texture = load(items["ingredients"][str(info)]["icon"])
		$MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Panel/Screenshot/ColorRect.hide()


var page_section = 1
@onready var tab_type: Label = $MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/MarginContainer/TabType

func _on_tab_1_pressed() -> void:
	set_info("terry")
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/Ingredients.show()
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/Meals.hide()
	tab_set = 0
	tab_type.text = "Ingredient"
	tab_type.add_theme_color_override("font_color", Color("36a17c"))


func _on_tab_2_pressed() -> void:
	set_info("chknandwaffles")
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/Ingredients.hide()
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/Meals.show()
	tab_set = 1
	tab_type.text = "Meal"
	tab_type.add_theme_color_override("font_color", Color("a13535"))
