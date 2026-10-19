class_name Recipe extends Resource

@export var recipe_name: String
@export var ingredients : Array[Manager.FoodType]
#@export var food_groups_needed : Array[BaseFood.FoodGroup] #ugly ass name that I simply MUST change

#@export var cook_group_application_type: BaseFood.CookGroup

@export var required_ingredients: Array
@export var product : PackedScene

@export var food_group_array: Array[Recipe_Ingredient]
#var food_tags: Array[Recipe_Ingredient.food_tags]
