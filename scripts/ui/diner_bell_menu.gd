extends Control

##for testing only
@export var test_recipe_array: Array[Resource]


@export var recipe_UI_node: PackedScene
@export var recipes_container: GridContainer
@export var confirm_button: Button

@export_group("Min and max selection")
@export var count_selected: Label
@export var min_selectable_recipes: int 
@export var max_selectable_recipes: int 
var selected_recipes: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirm_button.visible = false
	
	#remove placeholder children from grid
	if (recipes_container.get_child_count() > 0):
		for n in recipes_container.get_children():
			recipes_container.remove_child(n)
			n.queue_free() 

	#spawn recipe ui node for every unlocked recipe (stored in manager)
	#for recipe in Manager.player_unlocked_recipes:
	for recipe in test_recipe_array: #made for testing
		var current_recipe_node: Node
		current_recipe_node = recipe_UI_node.instantiate()
		
		# set recipe data #
		current_recipe_node.ui_label.text = recipe.recipe_name
		current_recipe_node.ui_icon.texture = recipe.recipe_icon
		
		# add recipe as child #
		recipes_container.add_child(current_recipe_node)
		
		# signal that listens for button press #
		current_recipe_node.node_toggled.connect(on_node_toggled)


func on_node_toggled(toggled_on: bool):
	if (toggled_on):
		# dont allow selection after max #
		if (selected_recipes >= max_selectable_recipes):
			return
		
		selected_recipes += 1
		#print("node toggled on!")
	else:
		selected_recipes -= 1
		#print("node toggled off!")

func _process(_delta: float) -> void:
	
	# updating selection count UI #
	count_selected.text = str(selected_recipes) + "/" + str(max_selectable_recipes)
	
	# showing confirmation button #
	if (selected_recipes >= min_selectable_recipes):
		confirm_button.visible = true
	else:
		confirm_button.visible = false
	
	# preventing selection past maximum #
	if (selected_recipes >= max_selectable_recipes):
		for n in recipes_container.get_children():
			if (n.ui_button.button_pressed == false):
				n.ui_button.disabled = true
	elif (selected_recipes < max_selectable_recipes):
		for n in recipes_container.get_children():
			if (n.ui_button.button_pressed == false):
				n.ui_button.disabled = false
