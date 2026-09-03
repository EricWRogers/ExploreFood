extends Node3D

var extended = false

func bite():
	$AnimationPlayer.play("Chomp")

func close():
	$AnimationPlayer.play_backwards("Chomp")

	
