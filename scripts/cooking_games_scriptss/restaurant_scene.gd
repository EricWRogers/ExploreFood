extends Node3D

signal add_new_customer()

const CUSTOMER_BEAN = preload("uid://cf8h7xtq160oq")

@onready var customer_points: Node3D = $CustomerPoints
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var customer_spawn: Marker3D = $CustomerSpawn
const CHICKEN_AND_WAFFLE = preload("uid://bh7bxo4knjirp")


var customer_spots = []
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
	for i in range (10):
		spawn_customer()


func spawn_customer():
	var customer = CUSTOMER_BEAN.instantiate()
	nav_region.add_child(customer)
	customer.global_position = customer_spawn.global_position
	customer.set_seat(pick_rand_spot())
	customer.set_exit(customer_spawn)
	customer.finished_eating.connect(customer_done)
	
func pick_rand_spot():
	var spot = customer_spots[randi_range(0, customer_spots.size() - 1)]
	customer_spots.erase(spot)
	return spot

func customer_done(fresh_spot : Object):
	customer_spots.append(fresh_spot)
	add_new_customer.emit() #testing purposes only

func new_customer():
	spawn_customer()
	var meal = CHICKEN_AND_WAFFLE.instantiate()
	add_child(meal)
	meal.global_position = Vector3(-0.766,0.664,-11.417)
