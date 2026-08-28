extends Resource
class_name ingredient_resource

enum FoodType {
	FRUIT, 
	VEGATABLE, 
	GRAIN,
	MEAT
}

enum FlavorType {
	SWEET,
	SALTY,
	SOUR,
	SPICY,
	BITTER,
	UMAMI,
	GREASY,
	LIKE_NOTHING_ELSE,
	DISGUSTING
}

@export var name : String 
@export var flavor_text : String 
@export var rarity_level : int = 1
@export var category : FoodType
@export var flavor : FlavorType
@export var model : Mesh
@export var mat : Material

# flavor profile
# 3D model information
