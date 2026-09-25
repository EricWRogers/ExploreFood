extends CharacterBody3D

signal finished_eating(spot : Vector3)

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer
@onready var texture_progress_bar: TextureProgressBar = $SubViewport/TextureProgressBar
@onready var timer_progress: Sprite3D = $TimerProgress
@onready var coin_spawn: Marker3D = $CoinSpawn
@onready var coin_payer: Timer = $CoinPayer

const GOLD_COIN = preload("uid://3plpvx8a7yxk")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var can_take_food : bool = false
var is_paying: bool = false
var my_seat : Object
var my_exit: Object
var order_distance = 1
var angry_time = 15.0

enum State{
	SEAT,
	ORDER,
	LEAVE,
	PAY
}

var current_state : State = State.SEAT

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

		State.LEAVE:
			state_leave(delta)
		
		State.PAY:
			state_pay(delta)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	exit_state(current_state)
	current_state = new_state
	enter_state(current_state)
	
func enter_state(state: State) -> void:
	match state:
		State.SEAT:
			timer_progress.hide()
			pass
		State.ORDER:
			timer_progress.show()
			pass

		State.LEAVE:
			timer_progress.hide()
			pass
		
		State.PAY:
			timer_progress.hide()
			pass


func exit_state(state: State) -> void:
	match state:
		State.SEAT:
			pass
		State.ORDER:
			pass

		State.LEAVE:
			pass
			
		State.PAY:
			pass
		
func state_seat(_delta : float):
	if global_position.distance_squared_to(my_seat.global_position) < 1.0:
		change_state(State.ORDER)
	nav_agent.set_target_position(my_seat.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
		
	velocity = (next_nav_point - global_position).normalized() * SPEED
	move_and_slide()

func state_order(_delta: float):
	if !can_take_food:
		set_order()
	if timer.is_stopped():
		timer.wait_time = angry_time
		timer.start()
		texture_progress_bar.max_value = 100.0
		texture_progress_bar.value = 100.0

	pass
	
func state_leave(_delta : float):
	if global_position.distance_squared_to(my_exit.global_position) < 1.0:
		finished_eating.emit(my_seat)
		queue_free()
	nav_agent.set_target_position(my_exit.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
		
	velocity = (next_nav_point - global_position).normalized() * SPEED
	move_and_slide()
	
func state_pay(_delta: float) -> void:
	if !is_paying:
		is_paying = true
		var tip = int(timer.time_left / 5.0)
		timer.stop()
		
		for money in range(tip):
			var coin = GOLD_COIN.instantiate()
			get_tree().current_scene.add_child(coin)
			coin.global_position = coin_spawn.global_position
			await get_tree().create_timer(1.0).timeout
		change_state(State.LEAVE)
	





func set_seat(new_target : Object):
	my_seat = new_target

func set_exit(new_exit: Object):
	my_exit = new_exit

func set_order():
	can_take_food = true
	if randi_range(1, 10) != 1: return
	#the res is code i stole from Caleb
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
		can_take_food = false
		change_state(State.PAY)
		body.queue_free()


func _on_timer_timeout() -> void:
	timer.stop()
	change_state(State.LEAVE)
	$Bubble.show()
	$Bubble/Bubble2.hide()
	$Bubble/Bubble3.hide()
	$Bubble/Label.text = "BAD SERVICE"
