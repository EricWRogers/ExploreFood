extends PathFollow3D

@export var colors: Array[Color]

var eagerness = 0.1

func _ready() -> void:
	var mat = $NPCBean/pTorus1.get_surface_override_material(0)
	mat.albedo_color = colors.pick_random()
	$NPCBean/pTorus1.set_surface_override_material(0, mat)
	eagerness = randf_range(0.08, 0.16)
	$NPCBean.position.x = randf_range(-1, 1)

func walking():
	$NPCBean/AnimationPlayer.play("Run")

func holding():
	$NPCBean/AnimationPlayer.play("Hold")
	
func _physics_process(delta: float) -> void:
	progress += eagerness
