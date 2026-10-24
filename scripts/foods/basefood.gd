extends RigidBody3D
class_name BaseFood

@export var food_name : String
@export var icon : Texture2D
@export var flavor_text : String

##determines spawn rate between 0 and 1. a value of 1 will always spawn and a value of 0 will never spawn
@export var rarity_level : float  
@export var rand_spin : bool = true
@export var id : int = 0
@export var color : Color
@export var type : String
@export var value : int
@export var hunger_restore : int
#@export var processed_ingredient : PackedScene
@export var is_prepped: bool = false

@export_group("Food Groups")
@export var food_group: FoodGroup
@export var prep_group: PrepGroup
@export var cook_group: CookGroup
##easier way to access all tags on ingredient at once
@onready var food_tags: Array = [food_group, prep_group, cook_group]

@export_subgroup("Depreciated")
@export var category : Manager.FoodType
@export var flavor : Manager.FlavorType

##type of food that an ingredient is. Must always have a value
enum FoodGroup {
	BREAD,
	MEAT,
	VEGGIE,
	BUTTER, #butter is a temp food group to be able to easily include butter frog in our prototype. 
	EGG #added because i didnt want to chop up Terry as a meat. I dont have any egg recipes yet though srry
}

##tracks how food has been prepped, if it has been prepped
enum PrepGroup {
	NONE,
	CHOPPED,
	FLATTENED
}

##tracks how food has been cooked, if it has been cooked
enum CookGroup {
	NONE,
	BAKED,
	GRILLED
}

@export_group("Appearance")
@export var chopped_mesh: Mesh
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

func _ready():
	overlay = mesh_instance.material_overlay.duplicate()
	next_pass = overlay.next_pass.duplicate()
	overlay.next_pass = next_pass
	mesh_instance.material_overlay = overlay
	
	if (prep_group == PrepGroup.CHOPPED):
		mesh_instance.mesh = chopped_mesh
	
	RollSpawn()
	if rand_spin:
		self.rotation_degrees.y = randi_range(0, 360)

func RollSpawn():
	var random = randf()
	
	if random >= rarity_level:
		queue_free()

func on_looked_at():
	next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D.show()
	
func on_looked_away():
	next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false
	
func im_food():
	pass
