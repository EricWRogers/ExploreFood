extends Node


var currently_held_food
var holding = false
var inventory = []

var slot1
var slot2
var slot3

enum FoodType {
	FRUIT, 
	VEGATABLE, 
	GRAIN,
	PASTA,
	LIQUID,
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
