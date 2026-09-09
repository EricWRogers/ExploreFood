extends PathFollow3D

@export var colors: Array[Color]
var hands_full = false

var eagerness = 0.1

func _ready() -> void:
	walking()
	var mat = $NPCBean/pTorus1.get_surface_override_material(0)
	mat.albedo_color = colors.pick_random()
	$NPCBean/pTorus1.set_surface_override_material(0, mat)
	eagerness = randf_range(0.08, 0.16)
	$NPCBean.position.x = randf_range(-1, 1)

func walking():
	$NPCBean/AnimationPlayer.play("Run")

func holding():
	$NPCBean/AnimationPlayer.play("Hold")
	
func _physics_process(_delta: float) -> void:
	progress += eagerness


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("get_rolled") and not hands_full:
		Manager.money += body.value
		Manager.player.update_cash()
		body.queue_free()
		hands_full = true
