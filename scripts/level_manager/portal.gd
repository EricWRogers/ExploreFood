extends Area3D

@export var image_of_world : Texture
@export var light_color: Color

@onready var mat = $Portalmesh.get_surface_override_material(0)

func _ready() -> void:
	mat.set_shader_parameter("albedo_texture", image_of_world)
