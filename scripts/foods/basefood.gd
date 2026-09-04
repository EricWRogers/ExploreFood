extends RigidBody3D
class_name BaseFood

@export var food_name : String
@export var icon : Texture2D
@export var flavor_text : String
@export var rarity_level : float #determines spawn rate between 0 and 1. a value of 1 would always spawn and a value of 0 would never spawn 
@export var category : Manager.FoodType
@export var flavor : Manager.FlavorType
@export var rand_spin : bool = true
@export var id : int = 0
@export var color : Color
@export var type : String

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

func _ready():
	overlay = mesh_instance_3d.material_overlay.duplicate()
	next_pass = overlay.next_pass.duplicate()
	overlay.next_pass = next_pass
	mesh_instance_3d.material_overlay = overlay
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
