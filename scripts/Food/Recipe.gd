extends Resource
class_name Recipe

@export var name: String
@export var ingredients : Dictionary[ingredient_resource, int]
@export var product : Meal
