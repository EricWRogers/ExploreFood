extends Node2D

@export var flash_time: float

var pattern_to_solve = []
var pattern_player_input = []
var player_input_so_far : int = 0

var level : int = 1

var flash = create_tween()
var active_flash : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var adding_next_number : int
	var rng = RandomNumberGenerator.new()
	var number_of_pattern : int = 5
	
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
	#check if player was correct
	if pattern_to_solve.slice(0,level) == pattern_player_input.slice(0,level):
		print(pattern_to_solve.slice(0,level))
		print(pattern_player_input)
		level += 1
	
	
	#start next level
	player_input_so_far = 0
	pattern_player_input = []
	flashing_lights()


func flashing_lights() -> void:
	for i in pattern_to_solve.slice(0,level):
		print("i: %s" % i)
		print(pattern_to_solve)
		match i:
			1:
				active_flash.tween_property($Button, "modulate", Color(1,1,1), flash_time)
				active_flash.tween_property($Button, "modulate", Color(1,0,0), flash_time)
				print("red colors")
			2:
				active_flash = create_tween()
				active_flash.tween_property($Button2, "modulate", Color(1,1,1), flash_time)
				active_flash.tween_property($Button2, "modulate", Color(0,1,0), flash_time)
				print("green colors")
			3:
				active_flash = create_tween()
				active_flash.tween_property($Button3, "modulate", Color(1,1,1), flash_time)
				active_flash.tween_property($Button3, "modulate", Color(0,0,1), flash_time)
				print("blue colors")
			4:
				active_flash = create_tween()
				active_flash.tween_property($Button4, "modulate", Color(1,1,1), flash_time)
				active_flash.tween_property($Button4, "modulate", Color(1,1,0), flash_time)
				print("yellow colors")
			_:
				push_error("ERROR: Index overflow")
		
		await active_flash.finished

func _on_button_pressed() -> void:
	pattern_player_input.append(1) #red
	input_count()
	
func _on_button_2_pressed() -> void:
	pattern_player_input.append(2) #green
	input_count()

func _on_button_3_pressed() -> void:
	pattern_player_input.append(3) #blue
	input_count()

func _on_button_4_pressed() -> void:
	pattern_player_input.append(4) #yellow
	input_count()

func input_count():
	player_input_so_far += 1
	print(pattern_player_input)
	if player_input_so_far >= level:
		check_answer()
