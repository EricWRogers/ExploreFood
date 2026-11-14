class_name Recipe extends Resource

@export var recipe_name: String
@export var recipe_ingredients: Array[PackedScene]
@export var recipe_outputs: Array[Texture2D]
@export var recipe_steps: Array[Manager.Stations]
@export var final_recipe_station: Manager.Stations
@export var recipe_station_tex: Texture2D
@export var product : PackedScene
@export var recipe_icon: Texture2D
@export var id : int
@export var screenshot : Texture2D



@export_group("depreciated")
## depreciated. Kept to prevent old recipes from breaking
@export var food_group_array: Array[Recipe_Ingredient]
## ultra super depriciated. 
#@export var ingredients : Array[Manager.FoodType]

func check_validity(current_ingredients: Array, current_station: Manager.Stations):
	if((current_ingredients == recipe_ingredients) && (current_station == final_recipe_station)):
		return true
	else:
		return false
