extends Control

signal start_button_hit


@onready var ingredient_texture = preload("res://scenes/UI/Diner/recipe_ingredient_flow.tscn")

##for testing only
@export var test_recipe_array: Array[Resource]

@export var recipe_UI_node: PackedScene
@export var recipes_container: GridContainer
@export var confirm_button: Button
@export var max_customers_label: Label

@export_group("Min and max selection")
@export var count_selected: Label
@export var min_selectable_recipes: int
@export var max_selectable_recipes: int
var num_selected_recipes: int = 0


func _ready() -> void:
	
	# setup variables #
	confirm_button.visible = false
	confirm_button.pressed.connect(confirm_recipes)
	Manager.player_selected_recipes.clear()
	max_customers_label.text = str(Manager.max_customers) + " customers will be dining with us today!"

	# remove placeholder children from grid #
	if (recipes_container.get_child_count() > 0):
		for n in recipes_container.get_children():
			recipes_container.remove_child(n)
			n.queue_free()

	# spawn recipe ui node for every unlocked recipe (stored in manager) #
	#for recipe in test_recipe_array: # <-- made for testing
	for recipe in Manager.player_unlocked_recipes:
		var current_recipe_node: Node
		current_recipe_node = recipe_UI_node.instantiate()

		# set recipe data #
		current_recipe_node.ui_recipe = recipe
		current_recipe_node.ui_label.text = recipe.recipe_name
		current_recipe_node.ui_icon.texture = recipe.recipe_icon
		current_recipe_node.ui_station.texture = recipe.recipe_station_tex
		for item in recipe.recipe_ingredients:
			var ingredient_tex = ingredient_texture.instantiate()
			current_recipe_node.ui_flow.add_child(ingredient_tex)
			var item_pull = item.instantiate()
			if item_pull.icon != null:
				ingredient_tex.texture = item_pull.icon
		# REMOVED: node_toggled.connect(confirm_recipes)

		# add recipe as child of container #
		recipes_container.add_child(current_recipe_node)

		# signal that listens for button press #
		current_recipe_node.node_toggled.connect(on_node_toggled)


func on_node_toggled(toggled_on: bool, ui_recipe: Recipe):
	if (toggled_on):

		# dont allow selection after max #
		if (num_selected_recipes >= max_selectable_recipes):
			return

		Manager.player_selected_recipes.append(ui_recipe)

		num_selected_recipes += 1
		#print("node toggled on!")
	else:
		num_selected_recipes -= 1
		Manager.player_selected_recipes.erase(ui_recipe)
		#print("node toggled off!")


func _process(_delta: float) -> void:
	
	# updating selection count UI #
	count_selected.text = str(num_selected_recipes) + "/" + str(max_selectable_recipes)

	# showing confirmation button #
	if (num_selected_recipes >= min_selectable_recipes):
		confirm_button.visible = true
	else:
		confirm_button.visible = false

	# preventing selection past maximum #
	if (num_selected_recipes >= max_selectable_recipes):
		for n in recipes_container.get_children():
			if (n.ui_button.button_pressed == false):
				n.ui_button.disabled = true
	elif (num_selected_recipes < max_selectable_recipes):
		for n in recipes_container.get_children():
			if (n.ui_button.button_pressed == false):
				n.ui_button.disabled = false


func _on_button_pressed() -> void:
	start_button_hit.emit()
	# send signal to diner menu board #
	

func confirm_recipes():
	get_tree().paused = false
	print(Manager.player_selected_recipes)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
