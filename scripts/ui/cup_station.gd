extends StaticBody3D


@onready var mesh_instance: MeshInstance3D = $CupPile
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

@onready var to_be_made = preload("res://scenes/scenes_assets/filledcup.tscn")

var _currently_at := false
var player_close = false;
var aplayer
var filling := false

func _process(_delta: float) -> void:
	if player_close and Input.is_action_just_pressed("Interact"):
		pass
	

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
	tween.tween_property(%Sprite3D, "scale", Vector3(0.7, 0.7, 0.7), 0.2)
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
	if filling:
		return
	#if player.get_held_item != null:
		#player.get_held_item().hide()
	if not aplayer.inventory.has(null):
		#cup.queue_free()
		filling = false
		return
	else:
		filling = true
		aplayer = player
		aplayer.hide()
		player.current_station = self
		player.can_move = false
		$"../KitchenProps/Counters/FrontWallCounters/Counter_Sink/Cuttingboard".show()
		CameraManager.switch_to_sink()
		$"../KitchenProps/Counters/FrontWallCounters/Counter_Sink/AnimationPlayer".play("fill")
		#CameraManager.switch_to_sink()
		#cup.show()
		#cup = null
		#food_in = false
		#$Check.hide()
		return
	#rush_button_hit.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fill":
		give_cup()
		$"../KitchenProps/Counters/FrontWallCounters/Counter_Sink/Cuttingboard".hide()

func give_cup():
	aplayer.current_station = null
	aplayer.can_move = true
	aplayer.show()
	CameraManager.switch_to_regular()
	filling = false
	var cup = to_be_made.instantiate()
	get_tree().current_scene.add_child(cup)
	aplayer.pickup_item(cup)
