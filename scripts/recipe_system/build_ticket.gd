extends Node

##takes a recipe resource
@export var current_recipe: Recipe
##gets array of ingredients in recipe
var recipe_ingredients: Array[PackedScene]
##gets name of dish
var dish_name: String
##determines which appliance is used (unsure if this is best method)
@export var appliance_needed: APPLIANCES

enum APPLIANCES {
	PAN,
	CUTTING_BOARD
}


func _ready() -> void:
	if(current_recipe == null):
		printerr("ERROR: Recipe not found!")
		return
	
	recipe_ingredients = current_recipe.ingredients
	dish_name = current_recipe.recipe_name
