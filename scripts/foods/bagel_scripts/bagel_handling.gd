extends RigidBody3D

@onready var mesh_children: Array[MeshInstance3D] = []
var shared_material: ShaderMaterial

const BAGEL_SPREAD_PIECE = preload("uid://bg30cyd7f3v1o")
const BAGEL_TOP = preload("uid://d13rs5g0a2u0r")
@export var icon : Texture2D
@export var id : int
@export var type : String

@onready var mesh_instance_3d: MeshInstance3D = $Bagel
@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
@onready var moving_lines_pass := overlay.next_pass as ShaderMaterial


var current_top
var thickness_of_spread = 0.076
var held = false

func _ready() -> void:
	current_top = self.global_position
	
func set_shaders():
	pass

func add_spread(color):
	var bagel_spread = BAGEL_SPREAD_PIECE.instantiate()
	add_child(bagel_spread)
	bagel_spread.global_position = current_top
	bagel_spread.change_color(color)
	current_top.y += thickness_of_spread
	$CollisionShape3D.shape.height += thickness_of_spread
	$CollisionShape3D.position.y += thickness_of_spread / 2
	$Node3D.position.y += thickness_of_spread
	print(str("current_top", current_top))
	mesh_children.append(bagel_spread.get_child(0))
	
func add_top():
	var bagel_top = BAGEL_TOP.instantiate()
	add_child(bagel_top)
	bagel_top.global_position = current_top
	show()
	mesh_children.append(bagel_top.get_child(0))
	set_shaders()

func on_looked_at():
	if held:
		return
	mesh_instance_3d.set_instance_shader_parameter("transparency", 0.411)
	$Node3D.show()
	
func on_looked_away():
	mesh_instance_3d.set_instance_shader_parameter("transparency", 0.0)
	$Node3D.hide()
	
func _process(delta: float) -> void:
	if held:
		self.global_position = Manager.player_hold.global_position

func get_took():
	self.set_collision_layer_value(10, false)
	self.freeze = true
	#Manager.currently_held_bagel = self
	held = true
	#queue_free()
	
func get_rolled():
	pass
	#self.freeze = false
