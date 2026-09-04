extends Node

signal scene_change

var currently_held_food
var holding = false
var inventory = []
var player_hold
var currently_held_bagel
var bagel_mode

var slot1
var slot2
var slot3

var slotb1
var slotb2
var slotb3


enum FoodType {
	FRUIT, 
	VEGATABLE, 
	GRAIN,
	PASTA,
	DAIRY,
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

enum PrepType {
	SOLID,
	LIQUID,
	POWDER,
	CHOPPED,
	MIXED,
	FRIED
}
