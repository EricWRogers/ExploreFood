class_name base_meal extends RigidBody3D

@export var meal_name: String
@export var flavor_text: String
@export var id : int = 0

@export var icon : Texture2D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
#@onready var overlay := mesh_instance_3d.material_overlay as ShaderMaterial
#@onready var next_pass := overlay.next_pass as ShaderMaterial

func _ready():
	pass
	#overlay = mesh_instance_3d.material_overlay.duplicate()
	#next_pass = overlay.next_pass.duplicate()
	#overlay.next_pass = next_pass
	#mesh_instance_3d.material_overlay = overlay

func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false
