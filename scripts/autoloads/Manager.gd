extends Node

var recipe_book
var collected_food : Array
var money : int
var inventory : Array
var player

var encountered_ingredients : Array = ["res://scenes/BaseIngredientFoods/mystery_meat.tscn"]
var encountered_meals : Array = ["res://scripts/resources/RecipesNew/BeefWellington.tres"]

var max_hotbar_slots := 6
var player_current_hovered_slot : int
var current_control_device : String = "keyboardmouse"

## ─────────────────────────────────────────
## Cooking and Restaurant Management
## ─────────────────────────────────────────

var player_unlocked_recipes = []
var player_selected_recipes: Array[Recipe] = []
var max_customers : int

## ─────────────────────────────────────────
## Level Managment
## ─────────────────────────────────────────
var level_manager: LevelManager
#soon to be depreciated
var is_portal_1: bool = true
var is_portal_2: bool = true

## ─────────────────────────────────────────
## Dialogue, Tutorial and Quests 
## ─────────────────────────────────────────
@export var current_quest_item : String
var dialogue_tree_index : int = 0
var is_tut_over: bool = false

var slot1
var slot2
var slot3

var slotb1
var slotb2
var slotb3

## ─────────────────────────────────────────
## Cook Sys
## ─────────────────────────────────────────

enum Stations {
	CUTTING_BOARD,
	PAN_GRILL,
	OVEN,
	ROLLING_PIN,
	NONE,
}

var tutorial_seen = false

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

##DEPRECIATED. Keeping to avoid breaking current prototype. Use enum FoodGroup instead!!
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

##DEPRECIATED. Keeping to avoid breaking current prototype. Use enum PrepGroup instead!!
enum PrepType {
	SOLID,
	LIQUID,
	POWDER,
	CHOPPED,
	MIXED,
	FRIED
}

#called when script is instantiated. 
func _init() -> void:
	print("game manager init")

func _ready() -> void:
	print("Portal 1 unlocked = ", is_portal_1, "\n Portal 2 unlocked = ", is_portal_2)
