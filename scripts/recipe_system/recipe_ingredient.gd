class_name Recipe_Ingredient extends Resource

@export var food_group: BaseFood.FoodGroup
@export var prep_group: BaseFood.PrepGroup
@export var cook_group: BaseFood.CookGroup
var food_tags: Array = [food_group, prep_group, cook_group]
