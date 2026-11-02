class_name Recipe extends Resource

@export var recipe_name: String

##ingredients that the recipe needs
@export var recipe_ingredients: Array[PackedScene]
##station that the recipe is made at (does this need to be stations plural?)
@export var recipe_station: Manager.Stations

## recipe output
@export var product : PackedScene

@export_group("depreciated")
## depreciated. Kept to prevent old recipes from breaking
@export var food_group_array: Array[Recipe_Ingredient]
## ultra super depriciated. 
#@export var ingredients : Array[Manager.FoodType]


func check_validity(current_ingredients: Array, current_station: Manager.Stations):
	if((current_ingredients == recipe_ingredients) && (current_station == recipe_station)):
		return true
	else:
		return false
