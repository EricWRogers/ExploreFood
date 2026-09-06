extends Node3D

@onready var debris: GPUParticles3D = $Debris
@onready var fire: GPUParticles3D = $Fire

func explode() -> void:
	debris.emitting = true
	fire.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
