extends Node3D

signal add_new_customer()

const CUSTOMER_BEAN = preload("uid://cf8h7xtq160oq")

@export var customer_points: Node3D 
@export var nav_region: NavigationRegion3D 
@export var customer_spawn: Marker3D 
const CHICKEN_AND_WAFFLE = preload("uid://bh7bxo4knjirp")

var is_rush_hour : bool = false


var customer_spots = []
var current_customers = []
#this controls when customers spawn and where their seats
#the nitty gritty stuff is in customer_bean.gd
#Summary:
#connects signal to customer spawner
#puts all valid seats into a list
#when customer is done they emit signal
#that signal tells this script their spot is open and adds it back to the list
func _ready():
	add_new_customer.connect(new_customer)
	customer_spots = customer_points.get_children()
	for i in range (2):
		spawn_customer()


func spawn_customer():
	var customer = CUSTOMER_BEAN.instantiate()
	nav_region.add_child(customer)
	customer.global_position = customer_spawn.global_position
	customer.set_seat(pick_rand_spot())
	customer.set_exit(customer_spawn)
	customer.finished_eating.connect(customer_done)
	current_customers.append(customer)
	
func pick_rand_spot():
	var spot = customer_spots[randi_range(0, customer_spots.size() - 1)]
	customer_spots.erase(spot)
	return spot

func customer_done(fresh_spot : Object, customer : Object):
	customer_spots.append(fresh_spot)
	current_customers.erase(customer)
	if is_rush_hour or current_customers.size() < 2:
		spawn_customer()

func new_customer():
	spawn_customer()
	var meal = CHICKEN_AND_WAFFLE.instantiate()
	add_child(meal)
	meal.global_position = Vector3(-0.766,0.664,-11.417)

func start_rush_hour():
	is_rush_hour = true
	for i in range(customer_spots.size()/ 2):
		spawn_customer()
		
func stop_rush_hour():
	is_rush_hour = false
	
func rush_button():
	if is_rush_hour:
		stop_rush_hour()
	else:
		start_rush_hour()


func _on_dinner_bell_rush_button_hit() -> void:
	rush_button()
