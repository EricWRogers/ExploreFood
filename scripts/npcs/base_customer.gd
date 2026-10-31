extends CharacterBody3D



## name
@export var customer_name: String
## color 
@export var customer_color: Color
## preferences ?

## relationship level
var relationship: int = 0

#mesh
@onready var customer_mesh: MeshInstance3D = $BodyMeshInstance

# change color #
func _ready() -> void:
	var customer_mat = customer_mesh.get_surface_override_material(0)
	customer_mat.albedo_color = customer_color

# request food on menu #


# movement #
