extends PathFollow3D
@export var colors: Array[Color]
var hands_full = false
var satisfied = false
var my_sandwich
var eagerness = 0.1
var impulse_force = 0.5
var done_1 = false
var done_2 = false
var money_wait = false

const MONEY_BAG = preload("uid://diredsx2k2vog")
const GOLD_COIN = preload("uid://3plpvx8a7yxk")
var accepting = false

func _ready() -> void:
	if !Manager.the_asker:
		var rand = randf()
		if rand <= 0.5:
			Manager.the_asker = self
			ask()
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
	#print(accepting)
	if money_wait:
		return
	if progress_ratio > 0.44 and progress_ratio < 0.48:
		accepting = true
	else:
		accepting = false
	if progress_ratio >= 0.98:
		Manager.current_customers -= 1
		if Manager.the_asker == self:
			Manager.the_asker = null
		if my_sandwich:
			my_sandwich.sandbot()
		queue_free()
	if Manager.the_asker == self:
		if !satisfied:
			if progress_ratio <= 0.45:
				progress += eagerness
		else:
			progress += eagerness
	else:
		progress += eagerness
		
func money_wait_switch():
	if done_1 and done_2:
		money_wait = false

func ask():
	$Bubble.show()
	for i in range(0,2):
		var rand = randi_range(1, 6)
		var to_change
		if i == 1:
			to_change = $Bubble/Bubble2
		else:
			to_change = $Bubble/Bubble3
		match rand:
			1:
				to_change.texture = Manager.TERRY_ICON
				Manager.askers_request.append(1)
			2:
				to_change.texture = Manager.WAFFLE_ICON
				Manager.askers_request.append(2)
			3:
				to_change.texture = Manager.BUTTERFROG_ICON
				Manager.askers_request.append(3)
			4:
				to_change.texture = Manager.DOUGH_BABY_ICON_NEW
				Manager.askers_request.append(7)
			5:
				to_change.texture = Manager.DROPLET_ICON
				Manager.askers_request.append(5)
			6:
				to_change.texture = Manager.MEAT_BALL
				Manager.askers_request.append(8)
	Manager.askers_request.sort()
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if accepting == false:
		return
	if body.has_method("get_rolled") and Manager.the_asker == self:
		if body.has_method("sandbot"):
			if Manager.askers_request == body.ids:
				body.make_inactive()
				#Manager.money += body.value
				spawn_value(body.value * 3)
				Manager.player.update_cash()
				body.holder = $Marker3D
				body.held = true
				#body.queue_free()
				hands_full = true
				$Bubble/Success.show()
				satisfied = true
				my_sandwich = body
				Manager.askers_request.clear()
			else:
				return
	if body.has_method("get_rolled") and not hands_full:
		body.make_inactive()
		#Manager.money += body.value
		spawn_value(body.value)
		Manager.player.update_cash()
		body.holder = $Marker3D
		body.held = true
		#body.queue_free()
		hands_full = true
		my_sandwich = body
		
func spawn_value(value: int) -> void:
	money_wait = true
	var ten_count = value / 10
	var one_count = value % 10
	
	for i in range(ten_count):
		spawn_item(10)
		await get_tree().create_timer(0.7).timeout
	done_1 = true
	money_wait_switch()
	for i in range(one_count):
		spawn_item(1)
		await get_tree().create_timer(0.3).timeout
	done_2 = true
	money_wait_switch()
func spawn_item(item_value: int) -> void:
	var item
	
	if item_value == 10:
		item = MONEY_BAG.instantiate()
	else:
		item = GOLD_COIN.instantiate()
	
	get_tree().current_scene.add_child(item)
	item.global_position = $MoneySpawn.global_position
	var forward_dir = -$NPCBean.global_transform.basis.z
	forward_dir = (forward_dir + Vector3(randf_range(-0.05, 0.05), randf_range(-0.05, 0.05), randf_range(-0.05, 0.05))).normalized()
	var impulse_vector = forward_dir * impulse_force
	item.apply_central_impulse(impulse_vector)
