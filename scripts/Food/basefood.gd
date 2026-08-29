extends Node3D
class_name BaseFood

enum FoodType {
	FRUIT, 
	VEGATABLE, 
	GRAIN,
	PASTA,
	MILK,
	CHEESE,
	EGG,
	MEAT,
	FISH
}

enum FlavorType {
	SWEET,
	SALTY,
	SOUR,
	SPICY,
	SAVORY,
	BITTER,
	GREASY,
	LIKE_NOTHING_ELSE,
	DISGUSTING
}

@export var food_name : String 
@export var flavor_text : String 
@export var rarity_level : float #determines spawn rate between 0 and 1. a value of 1 would always spawn and a value of 0 would never spawn 
@export var category : FoodType
@export var flavor : FlavorType

func _ready():
	RollSpawn()

func RollSpawn():
	var random = randf()
	
	if random <= rarity_level:
		print("I am terry and I survived.")
	else: 
		print("Terry Died.")
		queue_free()
