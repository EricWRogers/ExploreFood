extends Node3D

@onready var tears: GPUParticles3D = $Tears

func start_cry():
	tears.emitting = true

func stop_cry():
	tears.emitting = false
