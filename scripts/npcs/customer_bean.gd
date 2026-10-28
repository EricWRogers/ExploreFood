extends CharacterBody3D

signal finished_eating(spot : Vector3)

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer
@onready var texture_progress_bar: TextureProgressBar = $SubViewport/TextureProgressBar
@onready var timer_progress: Sprite3D = $TimerProgress
@onready var coin_spawn: Marker3D = $CoinSpawn

const GOLD_COIN = preload("uid://3plpvx8a7yxk")
const FOOD_TRAY = preload("uid://cwtpfule1qklh")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var can_take_food : bool = false
var is_paying: bool = false
var is_eating: bool = true
var my_seat : Object
var my_exit: Object
var my_succulent_meal
var order_distance = 1
var angry_time = 15.0
var satisfaction_time
var tray

enum State{
	SEAT,
	ORDER,
	EAT,
	PAY,
	LEAVE
}

var current_state : State = State.SEAT

#NOTE: State.EAT will spawn a food tray
#food tray has an animation to play and place the mat
#Take the food that enters the area then EITHER
#spawn a new one at foodTray.FoodSpawn OR just translate the meal
#once the animation finishes play ANOTHER timer to show eating
#when the timer runs out transition to State.PAY
func _process(_delta: float) -> void:

	if !timer.is_stopped():
		texture_progress_bar.value = (timer.time_left / timer.wait_time) * 100.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	match current_state:
		State.SEAT:
			state_seat(delta)

		State.ORDER:
			state_order(delta)
		
		State.PAY:
			state_pay(delta)
			
		State.EAT:
			state_eat(delta)
			
		State.LEAVE:
			state_leave(delta)
		

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	exit_state(current_state)
	current_state = new_state
	enter_state(current_state)
	
func enter_state(state: State) -> void:
	match state:
		State.SEAT:
			pass
			
		State.ORDER:
			timer_progress.show()
			timer.stop()
			set_order()
			timer.wait_time = angry_time
			timer.start()
			texture_progress_bar.max_value = 100.0
			texture_progress_bar.value = 100.0

			pass
			
		State.EAT:
			tray = FOOD_TRAY.instantiate()
			get_tree().current_scene.add_child(tray)
			tray.global_position = my_seat.get_child(0).global_position
			tray.global_rotation = my_seat.global_rotation
			tray.get_child(0).start_anim()
			
			timer_progress.show()
			timer.stop()
			timer.wait_time = angry_time
			timer.start()
			texture_progress_bar.max_value = 100.0
			texture_progress_bar.value = 100.0
			texture_progress_bar.tint_progress = Color.LIME_GREEN
			pass
			
		State.PAY:
			pass
			
		State.LEAVE:
			pass
		


func exit_state(state: State) -> void:
	match state:
		State.SEAT:
			pass
		State.ORDER:
			timer_progress.hide()
			timer.stop()
		
		State.EAT:
			tray.queue_free()
			my_succulent_meal.queue_free()

		State.PAY:
			pass
			
		State.LEAVE:
			pass
			
		
func state_seat(_delta : float):
	if global_position.distance_squared_to(my_seat.global_position) < 1.0:
		change_state(State.ORDER)
	nav_agent.set_target_position(my_seat.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED
	var move_direction = velocity
	move_direction.y = 0

	if move_direction.length_squared() > 0.001:
		look_at(global_position + move_direction, Vector3.UP)
	move_and_slide()

func state_order(_delta: float):
	var target_direction = my_seat.get_child(0).global_position - global_position
	target_direction.y = 0

	if target_direction.length_squared() > 0.001:
		look_at(global_position + target_direction, Vector3.UP)
	pass

func state_eat(_delta:float):
	pass
		

func state_pay(_delta: float) -> void:
	if !is_paying:
		is_paying = true
		var tip = int(satisfaction_time)
		timer.stop()
		
		for money in range(tip):
			print(tip)
			Manager.money +=1
			await get_tree().create_timer(1.0).timeout
		change_state(State.LEAVE)

func state_leave(_delta : float):
	if global_position.distance_squared_to(my_exit.global_position) < 1.0:
		finished_eating.emit(my_seat, self)
		queue_free()
	nav_agent.set_target_position(my_exit.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
		
	velocity = (next_nav_point - global_position).normalized() * SPEED
	var move_direction = velocity
	move_direction.y = 0

	if move_direction.length_squared() > 0.001:
		look_at(global_position + move_direction, Vector3.UP)
	move_and_slide()
	





func set_seat(new_target : Object):
	my_seat = new_target

func set_exit(new_exit: Object):
	my_exit = new_exit

func set_order():
	can_take_food = true
	return
	#ignore rest of it
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
	if body.has_method("get_took") and current_state == State.ORDER:
		satisfaction_time = timer.time_left
		can_take_food = false
		change_state(State.EAT)
		body.scale = Vector3.ONE * 0.5
		body.global_position = my_seat.get_child(0).global_position + Vector3.UP * 2.5
		
		var food = body as RigidBody3D
		food.linear_velocity = Vector3.ZERO
		food.global_rotation = Vector3.ZERO
		food.lock_rotation = true
		food.collision_layer = 2
		
		my_succulent_meal = food


func _on_timer_timeout() -> void:
	timer.stop()
	$Bubble.show()
	$Bubble/Bubble2.hide()
	$Bubble/Bubble3.hide()
	match current_state:
		State.ORDER:
			$Bubble/Label.text = "THIS SUCKS"
			change_state(State.LEAVE)
		State.EAT:
			$Bubble/Label.text = "Yummy"
			change_state(State.PAY)
