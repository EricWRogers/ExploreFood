extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $StoveOven/OvenSquish/DoorPivot/VintageOvenDoor
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

var _currently_at := false
var recipe : Array[PackedScene]
var ingredient_check : Array[PackedScene]
var station_finished := false
var _player: Node


func _focus_obtain():
	if _currently_at:
		return
	%Sprite3D.texture = InputManager.get_prompt("cook")
	$Node3D.show()
	%Sprite3D.scale = Vector3(.90, .90, .90)
	%Sprite3D.modulate = Color(0.0, 0.0, 0.0, 0.0)
	var tween
	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(%Sprite3D, "scale", Vector3(0.30, 0.30, 0.30), 0.2)
	tween.tween_property(%Sprite3D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	overlay.set_shader_parameter("transparency", 0.6)
	next_pass.set_shader_parameter("size", 1.02)
func _defocus():
	$Node3D.hide()
	%Sprite3D.scale = Vector3(.90, .90, .90)
	%Sprite3D.modulate = Color(0.0, 0.0, 0.0, 0.0)
	overlay.set_shader_parameter("transparency", 0.0)
	next_pass.set_shader_parameter("size", 0.0)

func _start_station(player):
	player.in_station = true
	$StoveOven/Door.play("open_door")
	_currently_at = true
	_defocus()
	CameraManager.switch_to_oven()
	_player = player
	recipe = player.current_recipe.recipe_ingredients
	ingredient_check = recipe.duplicate()
	station_finished = false
	for item in get_tree().get_nodes_in_group("Player"):
		item.can_move = false
		item._skin.hide()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_player.update_hotbar_eligibility()
func rip_away():
	_player.in_station = false
	if _player.get_held_item() != null:
		_player.get_held_item().show()
	$StoveOven/Door.play("close_door")
	_currently_at = false
	_defocus()
	CameraManager.switch_to_regular()
	_player = null
	#recipe = null
	#ingredient_check = recipe.duplicate()
	station_finished = true
	for item in get_tree().get_nodes_in_group("Player"):
		item.can_move = true
		item._skin.show()
		item.reset_hotbar_eligibility()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta: float) -> void:
	if _currently_at:
		if Input.is_action_just_pressed("Exit"):
			rip_away()
	
func get_eligibility(item) -> String:
	if item == null:
		return "none"
	for scene in ingredient_check:
		if scene.resource_path == item.scene_file_path:
			return "valid"
	return "invalid"
	
func consume(item) -> bool:
	for scene in ingredient_check:
		if scene.resource_path == item.scene_file_path:
			ingredient_check.erase(scene)
			station_finished = ingredient_check.is_empty()
			_player.update_hotbar_eligibility()
			return true
	return false

func update_station(ingredient):
	if ingredient in ingredient_check:
		ingredient_check.erase(ingredient)
	else:
		pass
		
