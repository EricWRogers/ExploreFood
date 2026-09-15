extends StaticBody3D

var timer_left = 100
@onready var sandwich_start_pnt: Marker3D = $SandwichStartPnt
const SANDWICH_BOTTOM = preload("uid://dv4r5bcwd2jap")
const SANDWICH_TOP = preload("uid://dlpov84bc1bse")

var recipe = []
var held_sandwich

func on_looked_at():
	#next_pass.set_shader_parameter("transparency", 0.5)
	$Node3D.show()
	
func on_looked_away():
	#next_pass.set_shader_parameter("transparency", 0.0)
	$Node3D.hide()

func assemble():
	if Manager.held_sandwich:
		return
	if held_sandwich:
		held_sandwich.on_picked()
		held_sandwich = null
		return
	Manager.current_assembler = self
	Manager.player.alive = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Manager.assemblerui.show()
	Manager.assemblerui.snapshot()
	print("assemble")
	
func sandwich_start():
	timer_left = 100
	
	$Timer.start()
	$AnimationPlayer.play("assemble")
	$SubViewport/TextureProgressBar.value = timer_left

func get_took():
	queue_free()
	
func get_rolled():
	self.freeze = false


func _on_timer_timeout() -> void:
	if timer_left > 0:
		timer_left -= 5
		$SubViewport/TextureProgressBar.value = timer_left
	else:
		$SubViewport/TextureProgressBar.value = 0
		$Timer.stop()
		$AnimationPlayer.play("RESET")
		self.set_collision_layer_value(10, true)
		var sandwich_bot = SANDWICH_BOTTOM.instantiate()
		get_tree().current_scene.add_child(sandwich_bot)
		sandwich_bot.global_position = sandwich_start_pnt.global_position
		var spawn_point = sandwich_bot.global_position
		var leader_chain = sandwich_bot
		held_sandwich = sandwich_bot
		sandwich_bot.my_assembler = self
		var new_lag = 1
		for item in recipe:
			var sandwich_piece = load(item).instantiate()
			var processed = sandwich_piece.processed_ingredient.instantiate()
			#processed.my_leader = leader_chain
			processed.in_chain = true
			get_tree().current_scene.add_child(processed)
			processed.global_position = spawn_point
			#leader_chain = spawn_point
			spawn_point = processed.get_node("StaticBody3D/AttchPnt").global_position
			processed.my_leader = leader_chain
			new_lag -= 0.03
			processed.id = sandwich_piece.id
			sandwich_bot.ids.append(sandwich_piece.id)
			processed.lag_amnt = new_lag
			processed.original_bun = sandwich_bot
			leader_chain = processed.get_node("StaticBody3D/AttchPnt")
			sandwich_bot.value += sandwich_piece.value
		var sand_top = SANDWICH_TOP.instantiate()
		get_tree().current_scene.add_child(sand_top)
		sand_top.global_position = spawn_point
		sand_top.my_leader = leader_chain
		sand_top.in_chain = true
		sand_top.lag_amnt = new_lag
		sand_top.original_bun = sandwich_bot
		
		
		
