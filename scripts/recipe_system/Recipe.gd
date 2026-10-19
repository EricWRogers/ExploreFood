class_name Recipe extends Resource

@export var recipe_name: String
@export var ingredients : Array[Manager.FoodType]
@export var food_group_array: Array[Recipe_Ingredient]
@export var product : PackedScene
