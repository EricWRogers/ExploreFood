extends HBoxContainer

@onready var recipe_nodes_container: VBoxContainer = $RecipeNodesContainer
@onready var final_ui_node: MarginContainer = $FinalUINode
const RECIPE_STEP_UI = preload("uid://cdrjspys6n4o2")
const RECIPE_PATH = preload("uid://ducx13b0gekbj")


@export var recipe : Resource

var Station_Icons = {
	Manager.Stations.CUTTING_BOARD: preload("res://fp_scenes/kitchen/textures/StovePixart.png"),
	Manager.Stations.PAN_GRILL: preload("res://fp_scenes/kitchen/textures/StovePixart.png"),
	Manager.Stations.OVEN: preload("res://fp_scenes/kitchen/textures/StovePixart.png"),
	Manager.Stations.ROLLING_PIN: preload("res://fp_scenes/kitchen/textures/StovePixart.png"),
	Manager.Stations.NONE: null,
}


func contruct_recipe():
	var reference = recipe
	var increment = 0
	for item in reference.recipe_ingredients:
		var recipe_step = RECIPE_STEP_UI.instantiate()
		var current_ingredient = item.instantiate()
		recipe_step.input.texture = current_ingredient.icon
		current_ingredient.queue_free()
		var current_step = recipe.recipe_steps[increment]
		recipe_step.station.texture = Station_Icons.get(current_step)
		recipe_step.output.texture = recipe.recipe_outputs[increment]
		recipe_nodes_container.add_child(recipe_step)
		increment += 1
	final_ui_node.station.texture = recipe.recipe_station_tex
	final_ui_node.output.texture = recipe.recipe_icon
	increment = 0
	for item in reference.recipe_ingredients:
		await get_tree().process_frame
		#await get_tree().process_frame
		#await get_tree().process_frame
		#await get_tree().process_frame
		var recipe_path = RECIPE_PATH.instantiate()
		$Lines.add_child(recipe_path)
		recipe_path.curve.set_point_position(0, recipe_nodes_container.get_child(increment).arrow_pnt.global_position)
		recipe_path.curve.set_point_position(1, final_ui_node.connection.global_position)
		recipe_path.update_line_from_path()
		increment += 1
