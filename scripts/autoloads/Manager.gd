extends Node

const BUTTERFROG_ICON = preload("uid://mgt6d08sqs17")
const DOUGH_BABY_ICON_NEW = preload("uid://bmqi2bed8i6o6")
const DROPLET_ICON = preload("uid://bbdqiesd6h5st")
const MEAT_BALL = preload("uid://dtnfe788cdn0k")
const TERRY_ICON = preload("uid://c4mrqsstnqfjk")
const WAFFLE_ICON = preload("uid://bapm1ifqtscdd")


signal scene_change

var currently_held_food
var holding = false
var current_slot
var inventory = []
var player_hold
var currently_held_bagel
var sandwich_mode
var player
var money : int = 0
var recipe_book
var kitchen_tut = 0
var level_1_tut = 0
var kitchen
var breakfast_unlocked = false
var belly = 100
var food_in_pot = []
var assemblerui
var current_assembler
var held_sandwich
var collected_food = []
var showed_sell = false
var the_asker
var askers_request = []
var current_customers = 0
var waffledimension = false

@export var current_quest_item : String

var slot1
var slot2
var slot3

var slotb1
var slotb2
var slotb3

func clear_current_bagel():
	player.dropthrow()
	player.update_slots(current_slot)


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
