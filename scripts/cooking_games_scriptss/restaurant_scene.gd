extends Node3D
const CUSTOMER_BEAN = preload("uid://cf8h7xtq160oq")

@onready var customer_points: Node3D = $CustomerPoints
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var customer_spawn: Marker3D = $CustomerSpawn

var customer_spots = []

func _ready():
	customer_spots = customer_points.get_children()
	spawn_customer()

func spawn_customer():
	var customer = CUSTOMER_BEAN.instantiate()
	nav_region.add_child(customer)
	customer.global_position = customer_spawn.global_position
	print("SPAWNED")
	customer.set_seat(pick_rand_spot().global_position)
	
func pick_rand_spot():
	var spot = customer_spots[randi_range(0, customer_spots.size())]
	customer_spots.erase(spot)
	return spot
