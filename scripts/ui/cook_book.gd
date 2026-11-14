extends CanvasLayer

const INGREDIENT_SELECTABLE = preload("uid://dhyn80ecousau")
const MEAL_SELECTABLE = preload("uid://kdojkkxie035")
const PINNED_RECIPE = preload("uid://dclapdxijuqwy")


@onready var ingredients_flow_container: FlowContainer = $MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Ingredients
@onready var meals_flow_container: FlowContainer = $MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Meals


@onready var name_of: Label = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/Name
@onready var flavor: Label = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/MarginContainer2/HBoxContainer/Flavor
@onready var family: Label = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/MarginContainer2/HBoxContainer/Family
@onready var desc: Label = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/Desc
@onready var location: Label = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/Location
@onready var screenshot: TextureRect = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/Panel/Screenshot

@export var ingredients : Array[String]
@export var meals : Array[String]

var tab_set = 1
var opened_amnt = 0

func _ready() -> void:
	Manager.recipe_book = self
	
func spawn_slots():
	#print(tab_set, "YO")
	reset_information()
	# if the player selects other worlds or filters spawn all even locked
	for slot in ingredients:
		var slot_string = str(slot)
		if slot_string.ends_with("tres"):
			var new_slot = MEAL_SELECTABLE.instantiate()
			var slot_information = load(slot)
			new_slot.icon_show = slot_information.recipe_icon
			new_slot.name_of = slot_information.recipe_name
			#new_slot.flavor = slot_information.flavor
			#new_slot.family = slot_information.family
			#new_slot.desc = slot_information.description
			#new_slot.location = slot_information.where_to_find
			new_slot.screenshot = slot_information.screenshot
			new_slot.book_owner = self
			new_slot.recipe = slot_information
			meals_flow_container.add_child(new_slot)
			if Manager.encountered_meals.has(slot):
				new_slot.become_active()
			new_slot.display_icon()
			#slot_information.queue_free()
		else:
			var new_slot = INGREDIENT_SELECTABLE.instantiate()
			var slot_information = load(slot).instantiate()
			new_slot.icon_show = slot_information.icon
			new_slot.name_of = slot_information.ingredient_name
			new_slot.flavor = slot_information.flavor
			new_slot.family = slot_information.family
			new_slot.desc = slot_information.description
			new_slot.location = slot_information.where_to_find
			new_slot.screenshot = slot_information.screenshot
			new_slot.book_owner = self
			ingredients_flow_container.add_child(new_slot)
			if Manager.encountered_ingredients.has(slot):
				new_slot.become_active()
			new_slot.display_icon()
			slot_information.queue_free()
	if tab_set == 0:
		$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Ingredients.show()
	elif tab_set == 1:
		$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Meals.show()
func unlock_slots():
	# show and make clickable the ones the player has encountered
	pass
func set_information(reference):
	if reference.type == "Ingredient" and tab_set == 0:
		$MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/Panel/Screenshot/NoImage.hide()
		$MarginContainer/HBoxContainer/TextureRect/NoIngredientsUnlocked.hide()
		$MarginContainer/HBoxContainer/TextureRect/IngInformationPanel.show()
		name_of.text = reference.name_of
		flavor.text = reference.flavor
		family.text = reference.family
		desc.text = reference.desc
		location.text = reference.location
		screenshot.texture = reference.screenshot
	elif reference.type == "Meal" and tab_set == 1:
		$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel/VBoxContainer/Panel/Screenshot/NoImage.hide()
		$MarginContainer/HBoxContainer/TextureRect/NoIngredientsUnlocked.hide()
		$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel.show()
		var current_recipe = reference.recipe
		var pinned = PINNED_RECIPE.instantiate()
		pinned.recipe = current_recipe
		$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel/VBoxContainer.add_child(pinned)
		pinned.contruct_recipe()
		$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel/VBoxContainer/Name.text = reference.name_of
		$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel/VBoxContainer/MarginContainer2/HBoxContainer/Flavor.text = reference.flavor
		$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel/VBoxContainer/Panel/Screenshot.texture = reference.screenshot
		#desc.text = reference.desc
	#name_of.text = reference.name_of
func reset_information():
	var container = $MarginContainer/HBoxContainer/TextureRect/MealInformationPanel/VBoxContainer
	var childe = container.get_node_or_null("PinnedRecipe")
	if childe:
		childe.queue_free()
	for child in ingredients_flow_container.get_children():
		child.queue_free()
	for child in meals_flow_container.get_children():
		child.queue_free()
	$MarginContainer/HBoxContainer/TextureRect/IngInformationPanel.hide()
	$MarginContainer/HBoxContainer/TextureRect/NoIngredientsUnlocked.show()
	$MarginContainer/HBoxContainer/TextureRect/MealInformationPanel.hide()
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Ingredients.hide()
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Meals.hide()
func appear():
	spawn_slots()
	$AnimationPlayer.play("Appear")

func disappear():
	$AnimationPlayer.play("Dissappear")
	reset_information()

#var items = {
	#"ingredients": {
		#"terry": {
			#"icon": "res://assets/ui/cook_book/screenshots/TerryScreenshot.png",
			#"name": "Man Eater Bird",
			#"unlocked": false,
			#"flavor": "Savory Flavor",
			#"family": "Egg Family",
			#"desc": "This bird is known to bite the heads off anything that comes near",
			#"found": "Found at high altitudes"
		#},
		#"waffle": {
			#"icon": "res://assets/ui/cook_book/screenshots/WaffleScreenshot.png",
			#"name": "Waffle Pad",
			#"unlocked": false,
			#"flavor": "Sweet Flavor",
			#"family": "Grain Family",
			#"desc": "They start as balls of dough on river beds. The molten syrupy water fully cooks them by the time they reach the surface.",
			#"found": "Found floating in rivers and ponds."
		#},
		#"butter": {
			#"icon": "res://assets/ui/cook_book/screenshots/FrogScreenshot.png",
			#"name": "Butter Frog",
			#"unlocked": false,
			#"flavor": "Creamy Flavor",
			#"family": "Dairy Family",
			#"desc": "These creatures are a rare sight to see. If they do not escape the rivers they spawn in quick enough they will melt away.",
			#"found": "Found outside but near rivers and ponds. Usually on waffle lily pads."
		#},
		#"doughbaby": {
			#"icon": "res://assets/ui/cook_book/screenshots/DoughBebehs.png",
			#"name": "DoughDough",
			#"unlocked": false,
			#"flavor": "Hearty Flavor",
			#"family": "Grain Family",
			#"desc": "Dough Doughs love to dance around in groups. Once mature they do not taste any good at all.",
			#"found": "Found in low altitudes plains."
		#},
		#"babytear": {
			#"icon": "res://assets/ui/cook_book/screenshots/TearBebehSS.png",
			#"name": "Willow Sap",
			#"unlocked": false,
			#"flavor": "Salty Flavor",
			#"family": "Sauce Family",
			#"desc": "Is it tears or tree sap? Regardless it makes for a delicious dipping sauce.",
			#"found": "Secreted from Weeping Willows after presenting the tree with an item."
		#},
		#"meatball": {
			#"icon": "res://assets/ui/cook_book/screenshots/MeatBallScreenshot.png",
			#"name": "Joker Fruit",
			#"unlocked": false,
			#"flavor": "Umami Flavor",
			#"family": "Meat Family",
			#"desc": "This meat will explode if you approach too suddenly. It is unsure what animal meat it is. Is it plant-based?",
			#"found": "Grows out of Joker Fronds when they bloom. Will explode if approached brazenly."
		#},
		#"chknandwaffles": {
			#"icon": "res://assets/ui/cook_book/screenshots/TerryScreenshot.png",
			#"name": "Chicken n Waffles",
			#"unlocked": false,
			#"flavor": "",
			#"family": "",
			#"desc": "A classic, popularized on a small planet known as earth.",
			#"found": "1 Bird + ??? + 1 Butter",
		#},
		#"meatpocket": {
			#"icon": "res://assets/ui/cook_book/screenshots/TerryScreenshot.png",
			#"name": "Meat Pockets",
			#"unlocked": false,
			#"flavor": "",
			#"family": "",
			#"desc": "Each bite is a juicy explosion that reminds you of better days. However, The sauce is a little unnerving.",
			#"found": "1 Dough + ??? + 1 Sauce"
		#},
	#}
#}

#func set_info(info):
	#if items["ingredients"][str(info)]["unlocked"] == false:
		#$MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Panel/Screenshot/ColorRect.show()
		#name_of.text = "Undiscovered"
		#name_of.add_theme_color_override("font_color", Color("000000ff"))
		#flavor.text = "Unknown"
		#family.text = "Unknown"
		#desc.text = ""
		#location.text = items["ingredients"][str(info)]["found"]
	#else:
		#name_of.text = items["ingredients"][str(info)]["name"]
		#match tab_set:
			#0:
				#name_of.add_theme_color_override("font_color", Color("36a17c"))
			#1:
				#name_of.add_theme_color_override("font_color", Color("a13535"))
		#flavor.text = items["ingredients"][str(info)]["flavor"]
		#family.text = items["ingredients"][str(info)]["family"]
		#desc.text = items["ingredients"][str(info)]["desc"]
		#location.text = items["ingredients"][str(info)]["found"]
		#screenshot.texture = load(items["ingredients"][str(info)]["icon"])
		#$MarginContainer/HBoxContainer/TextureRect/InformationPanel/VBoxContainer/Panel/Screenshot/ColorRect.hide()


var page_section = 1
#@onready var tab_type: Label = $MarginContainer/HBoxContainer/TextureRect/IngInformationPanel/VBoxContainer/MarginContainer/TabType

func _on_tab_1_pressed() -> void:
	if tab_set == 0:
		return
	tab_set = 0
	#reset_information()
	spawn_slots()
	#$TornPage.hide()
	#$Label.hide()
	#set_info("terry")
	#tab_set = 0
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Ingredients.show()
	#tab_type.text = "Ingredient"
	#tab_type.add_theme_color_override("font_color", Color("36a17c"))


func _on_tab_2_pressed() -> void:
	if tab_set == 1:
		return
	tab_set = 1
	#reset_information()
	spawn_slots()
	#$TornPage.hide()
	#$Label.hide()
	#set_info("chknandwaffles")
	$MarginContainer/HBoxContainer/TextureRect2/InformationPanel/MarginContainer/Meals.show()
	#tab_type.text = "Meal"
	#tab_type.add_theme_color_override("font_color", Color("a13535"))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Appear":
		spawn_slots()
