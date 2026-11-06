extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $StoveOven/OvenSquish/DoorPivot/VintageOvenDoor
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

@onready var checkmark = preload("res://fp_scenes/inputs/General/checkmark-64.png")

var _currently_at := false
var recipe : Array[PackedScene]
var ingredient_check : Array[PackedScene]
var station_finished := false
var _player: Node
var valid_dish : bool = false
var finished_cooking : bool = false
var currently_cooking : bool = false
var food_in : bool = false
var to_be_made : PackedScene
var dish
@export var cook_time : int

func _ready() -> void:
	CameraManager.oven_cam = $OvenCam
func _focus_obtain():
	if currently_cooking:
		return
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
	valid_dish = false
	if food_in:
		if not player.pickup_item(dish):
			return
		else:
			dish.show()
			dish = null
			food_in = false
			$Check.hide()
			return
	if currently_cooking:
		return
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
	InputManager.update_hotbar()
func rip_away():
	_player.current_station = null
	_player.in_station = false
	if _player.get_held_item() != null:
		_player.get_held_item().show()
	$StoveOven/Door.play("close_door")
	_currently_at = false
	_defocus()
	CameraManager.switch_to_regular()
	check_valid_dish()
	_player.display_cook_button(false)
	to_be_made = _player.current_recipe.product
	_player = null
	#recipe = null
	#ingredient_check = recipe.duplicate()
	station_finished = true
	for item in get_tree().get_nodes_in_group("Player"):
		item.can_move = true
		item._skin.show()
		item.reset_hotbar_eligibility()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InputManager.update_hotbar()
	InputManager.hotbar_icons.rip_away_reset()
	
func _process(delta: float) -> void:
	if _currently_at:
		if Input.is_action_just_pressed("Exit"):
			rip_away()
	
func get_eligibility(item) -> String:
	print(ingredient_check)
	if item == null:
		return "none"
	for scene in ingredient_check:
		if scene.resource_path == item.scene_file_path:
			return "valid"
	return "invalid"
	
func check_valid_dish():
	if ingredient_check.is_empty():
		_player.display_cook_button(true)
		valid_dish = true
	else:
		_player.display_cook_button(false)
		valid_dish = false

func start_cooking_time():
	currently_cooking = true
	$SubViewport/TextureProgressBar.value = 0
	$TextureRect.show()
	var tween = create_tween()
	tween.tween_property($SubViewport/TextureProgressBar, "value", 100.0, cook_time)
	
	tween.tween_callback(hold_dish)
func hold_dish():
	$TextureRect.hide()
	currently_cooking = false
	food_in = true
	$Check.show()
	#$SubViewport/TextureProgressBar.value = 0
	dish = to_be_made.instantiate()
	get_tree().current_scene.add_child(dish)
	dish.hide()
	
func update_station(ingredient):
	if ingredient in ingredient_check:
		ingredient_check.erase(ingredient)
	else:
		pass
		
