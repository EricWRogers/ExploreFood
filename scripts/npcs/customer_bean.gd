extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var has_ordered : bool = false
var my_seat : Vector3

enum State{
	SEAT,
	ORDER,
	LEAVE
}

var current_state : State = State.SEAT


func _physics_process(delta: float) -> void:
	# Add the gravity.
	match current_state:
		State.SEAT:
			state_seat(delta)

		State.ORDER:
			state_order(delta)

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
			pass

		State.LEAVE:
			pass


func exit_state(state: State) -> void:
	match state:
		State.SEAT:
			pass
		State.ORDER:
			pass

		State.LEAVE:
			pass
			
func state_seat(delta : float):
	if global_position.distance_squared_to(my_seat) < 1.0:
		change_state(State.ORDER)
	nav_agent.set_target_position(my_seat)
	var next_nav_point = nav_agent.get_next_path_position()
		
	velocity = (next_nav_point - global_position).normalized() * SPEED
	move_and_slide()

func state_order(delta: float):
	if !has_ordered:
		set_order()
	pass
	
func state_leave(delta : float):
	pass

func set_seat(new_target : Vector3):
	my_seat = new_target

func set_order():
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
	has_ordered = true
