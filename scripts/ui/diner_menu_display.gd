extends Control

#Manager.player_selected_recipes
@onready var ingredient_texture = preload("res://scenes/ui/Diner/recipe_ingredient_flow.tscn")
@export var recipe_UI_node: PackedScene
@export var recipes_container: GridContainer

@export var diner_bell: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# setup signal from diner bell menu#
	diner_bell.menu_set.connect(update_menu)
	
	# remove placeholder children from grid #
	if (recipes_container.get_child_count() > 0):
		for n in recipes_container.get_children():
			recipes_container.remove_child(n)
			n.queue_free()
	

func update_menu():
	print("updating menu display!")
	
	# spawn recipe ui node for every selected recipe (stored in manager) #
	for recipe in Manager.player_selected_recipes:
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
		
		# disable buttons #
		current_recipe_node.ui_button.disabled = true
	
		# add recipe as child of container #
		recipes_container.add_child(current_recipe_node)
