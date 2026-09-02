extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var animation_player: AnimationPlayer = $"../../../AnimationPlayer"
@onready var path_follow_3d: PathFollow3D = $".."


var player: Node3D
var speed := 25.0

var watch_distance := 15.0
var stranger_danger := 5.0
var distance_to_player_squared := 0.0


enum State {
	FROLIC,
	WATCH,
	RUN,
}

var current_state: State = State.WATCH


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player").get_child(0)

	if player == null:
		push_error("NO PLAYER FOUND")
		return
	

	change_state(State.FROLIC)


func _physics_process(delta: float) -> void:
	if player == null:
		return

	distance_to_player_squared = global_position.distance_squared_to(
		player.global_position
	)

	match current_state:
		State.FROLIC:
			state_frolic(delta)

		State.WATCH:
			state_watch(delta)

		State.RUN:
			state_run(delta)
	print(current_state)
	print(get_parent().name)


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	exit_state(current_state)
	current_state = new_state
	enter_state(current_state)


func enter_state(state: State) -> void:
	match state:
		State.FROLIC:
			#animation_player.play("Frolic")
			reparent(path_follow_3d)

		State.WATCH:
			pass

		State.RUN:
			pass


func exit_state(state: State) -> void:
	match state:
		State.FROLIC:
			animation_player.stop(false)
			reparent(get_node('/root') )

		State.WATCH:
			pass

		State.RUN:
			pass


func state_frolic(delta: float) -> void:
	# Move forward along the Path3D.
	path_follow_3d.progress += speed * delta
	# Check whether the player is nearby.
	if distance_to_player_squared < stranger_danger ** 2:
		change_state(State.RUN)

	elif distance_to_player_squared < watch_distance ** 2:
		change_state(State.WATCH)


func state_watch(delta: float) -> void:
	if distance_to_player_squared > watch_distance ** 2:
		change_state(State.FROLIC)

	elif distance_to_player_squared < stranger_danger ** 2:
		change_state(State.RUN)


func state_run(delta: float) -> void:
	if distance_to_player_squared > watch_distance ** 2:
		change_state(State.FROLIC)

	elif distance_to_player_squared > stranger_danger ** 2:
		change_state(State.WATCH)
