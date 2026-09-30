extends Node2D

var pattern_to_solve = []
var pattern_player_input = []
var adding_next_number : int

var number_of_pattern : int = 5
var round : int = 1
var rng = RandomNumberGenerator.new()

var player_input_so_far : int = 0

var flash = create_tween()
var active_flash : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.modulate = Color (1, 0, 0) #red = 1
	$Button2.modulate = Color (0, 1, 0) #green = 2
	$Button3.modulate = Color (0, 0, 1) #blue = 3
	$Button4.modulate = Color (1, 1, 0) #yellow = 4
	
	number_of_pattern = rng.randi_range(5,7)
	
	for x in number_of_pattern:
		adding_next_number = rng.randi_range(1,4)
		pattern_to_solve.append(adding_next_number)
		print(pattern_to_solve)
	print(pattern_to_solve)
	flashing_lights()
	

func check_answer() -> void:
	if pattern_to_solve.slice(0,round) == pattern_player_input.slice(0,round):
		print(pattern_to_solve.slice(0,round))
		print(pattern_player_input)
	flashing_lights()
	round += 1
	player_input_so_far = 0
	pattern_player_input = []
	


func flashing_lights() -> void:
	for i in pattern_to_solve.slice(0,round):
		print("i%s" % i)
		print(pattern_to_solve)
		#if pattern_to_solve.slice(0,round):
		if i == 1:
			active_flash = create_tween()
			#active_flash.tween_await(x * 1)
			active_flash.tween_property($Button, "modulate", Color(1,1,1), 0.5)
			active_flash.tween_property($Button, "modulate", Color(1,0,0), 0.5)
			print("red colors")
			#await active_flash.finished
			
		if i == 2:
			active_flash = create_tween()
			active_flash.tween_property($Button2, "modulate", Color(1,1,1), 0.5)
			active_flash.tween_property($Button2, "modulate", Color(0,1,0), 0.5)
			print("green colors")
			#await active_flash.finished
		
		if i == 3:
			active_flash = create_tween()
			active_flash.tween_property($Button3, "modulate", Color(1,1,1), 0.5)
			active_flash.tween_property($Button3, "modulate", Color(0,0,1), 0.5)
			print("blue colors")
			#await active_flash.finished
			
		if i == 4:
			active_flash = create_tween()
			active_flash.tween_property($Button4, "modulate", Color(1,1,1), 0.5)
			active_flash.tween_property($Button4, "modulate", Color(1,1,0), 0.5)
			print("yellow colors")
			#await active_flash.finished

func _on_button_pressed() -> void:
	pattern_player_input.append(1) #red
	player_input_so_far += 1
	print(pattern_player_input)
	if player_input_so_far >= round:
		check_answer()


func _on_button_2_pressed() -> void:
	pattern_player_input.append(2) #green
	player_input_so_far += 1
	print(pattern_player_input)
	if player_input_so_far >= round:
		check_answer()


func _on_button_3_pressed() -> void:
	pattern_player_input.append(3) #blue
	player_input_so_far += 1
	print(pattern_player_input)
	if player_input_so_far >= round:
		check_answer()


func _on_button_4_pressed() -> void:
	pattern_player_input.append(4) #yellow
	player_input_so_far += 1
	print(pattern_player_input)
	if player_input_so_far >= round:
		check_answer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
