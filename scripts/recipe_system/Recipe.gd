class_name Recipe extends Resource

@export var recipe_name: String

##ingredients that the recipe needs
@export var ingredients: Array[PackedScene]

## recipe output
@export var product : PackedScene

@export_group("depreciated")
## depreciated. Kept to prevent old recipes from breaking
@export var food_group_array: Array[Recipe_Ingredient]
## ultra super depriciated. 
#@export var ingredients : Array[Manager.FoodType]
