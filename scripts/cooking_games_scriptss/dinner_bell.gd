extends StaticBody3D
signal rush_button_hit

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial


var _currently_at := false
var player_close = false;

func _ready() -> void:
	Manager.player_unlocked_recipes.append(load("res://scripts/resources/RecipesNew/MeatSkewer.tres"))

func _process(delta: float) -> void:
	if player_close and Input.is_action_just_pressed("Interact"):
		rush_button_hit.emit()
	
func _focus_obtain():
	if _currently_at:
		return
	if Manager.player_unlocked_recipes.is_empty():
		return
	%Sprite3D.texture = InputManager.get_prompt("cook")
	$Node3D.show()
	%Sprite3D.scale = Vector3(.90, .90, .90)
	%Sprite3D.modulate = Color(0.0, 0.0, 0.0, 0.0)
	var tween
	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(%Sprite3D, "scale", Vector3(0.5, 0.5, 0.5), 0.2)
	tween.tween_property(%Sprite3D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	overlay.set_shader_parameter("transparency", 0.6)
	next_pass.set_shader_parameter("size", 1.02)
func _defocus():
	$Node3D.hide()
	%Sprite3D.scale = Vector3(.90, .90, .90)
	%Sprite3D.modulate = Color(0.0, 0.0, 0.0, 0.0)
	overlay.set_shader_parameter("transparency", 0.0)
	next_pass.set_shader_parameter("size", 0.0)
	
	$Node3D.hide()
func _start_station(player):
	rush_button_hit.emit()

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false
func start_rush_hour():
	rush_button_hit.emit()
