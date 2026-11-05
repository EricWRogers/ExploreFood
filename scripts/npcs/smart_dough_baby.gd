extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

@onready var base_nd: BaseIngredientND = $BaseND
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var running_point_1: Node3D = $"../EscapePoints/RunningPoint1"
@onready var running_point_2: Node3D = $"../EscapePoints/RunningPoint2"
@onready var running_point_3: Node3D = $"../EscapePoints/RunningPoint3"
@onready var running_point_4: Node3D = $"../EscapePoints/RunningPoint4"
@export var frolic_radius: float = 4.0
@export var frolic_speed: float = 2.0
@export var frolic_points: int = 12

var frolic_angle: float = 0.0
var frolic_center: Vector3



var player: Node3D
var anim_speed := 5.0

var watch_distance := 25.0
var stranger_danger := 10.0
var distance_to_player_squared := 0.0


enum State {
	FROLIC,
	WATCH,
	RUN,
	DEAD
}

var current_state: State = State.WATCH


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player").get_child(0)

	if player == null:
		push_error("NO PLAYER FOUND")
		return
	
	change_state(State.FROLIC)


func _physics_process(delta: float) -> void:
	#have to get player in update cuz level changing shenanigans
	if player == null:
		player = get_tree().get_first_node_in_group("Player").get_child(0)

	distance_to_player_squared = global_position.distance_squared_to(player.global_position)

	match current_state:
		State.FROLIC:
			state_frolic(delta)

		State.WATCH:
			state_watch(delta)

		State.RUN:
			state_run(delta)
			
		State.DEAD:
			pass



func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	exit_state(current_state)
	current_state = new_state
	enter_state(current_state)


func enter_state(state: State) -> void:
	match state:
		State.FROLIC:
			animation_player.play("Frolic")

			frolic_center = global_position
			frolic_angle = randf_range(0.0, TAU)

			set_next_frolic_target()

		State.WATCH:
			pass

		State.RUN:
			pass


func exit_state(state: State) -> void:
	match state:
		State.FROLIC:
			animation_player.stop()
		State.WATCH:
			pass

		State.RUN:
			pass



func state_frolic(delta: float) -> void:
	# Check whether the player is nearby.
	#if distance_to_player_squared < stranger_danger ** 2:
		#change_state(State.RUN)
		#return
	#elif distance_to_player_squared < watch_distance ** 2:
		#change_state(State.WATCH)
		#return

	# Pick the next point when we reach the current one.
	if navigation_agent_3d.is_navigation_finished():
		set_next_frolic_target()

	var next_nav_point = navigation_agent_3d.get_next_path_position()
	var direction = (next_nav_point - global_position).normalized()

	if direction.length_squared() > 0.001:
		look_at(global_position - direction, Vector3.UP)

	velocity = direction * frolic_speed
	move_and_slide()


func state_watch(_delta: float) -> void:
	if distance_to_player_squared > watch_distance ** 2:
		change_state(State.FROLIC)
	elif distance_to_player_squared < stranger_danger ** 2:
		change_state(State.RUN)

	var direction := (player.global_position - global_position).normalized()
	look_at(global_position - direction, Vector3.UP)
	
	
	#looks confusing but its just doubling the distance that decides if baby should run
	# basically Stare, when player gets closer move away, if too close start running
	if distance_to_player_squared < (stranger_danger ** 2) * 2:
		navigation_agent_3d.set_target_position(global_position - global_transform.basis.z)
		var next_nav_point = navigation_agent_3d.get_next_path_position()
		
		velocity = (next_nav_point - global_position).normalized() * SPEED
		move_and_slide()


func state_run(_delta: float) -> void:
	if distance_to_player_squared > watch_distance ** 2:
		change_state(State.FROLIC)
	elif distance_to_player_squared > stranger_danger ** 2:
		change_state(State.WATCH)

	var point1_distance = player.global_position.distance_squared_to(running_point_1.global_position)
	var point2_distance = player.global_position.distance_squared_to(running_point_2.global_position)
	var point3_distance = player.global_position.distance_squared_to(running_point_3.global_position)
	var point4_distance = player.global_position.distance_squared_to(running_point_4.global_position)

	var final_choice = running_point_1
	var farthest_distance = point1_distance

	if point2_distance > farthest_distance:
		final_choice = running_point_2
		farthest_distance = point2_distance

	if point3_distance > farthest_distance:
		final_choice = running_point_3
		farthest_distance = point3_distance

	if point4_distance > farthest_distance:
		final_choice = running_point_4

	var direction = (final_choice.global_position - global_position).normalized()
	look_at(global_position - direction, Vector3.UP)

	navigation_agent_3d.set_target_position(final_choice.global_position)

	var next_nav_point = navigation_agent_3d.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED * 2
	move_and_slide()

func is_dead():
	set_collision_layer_value(1, false)
	base_nd.set_collision_layer_value(1, false)
	reparent(get_tree().current_scene)
	change_state(State.DEAD)

func set_next_frolic_target() -> void:
	frolic_angle += TAU / frolic_points

	var target_position = frolic_center + Vector3(
		cos(frolic_angle) * frolic_radius,
		0.0,
		sin(frolic_angle) * frolic_radius
	)

	navigation_agent_3d.set_target_position(target_position)
