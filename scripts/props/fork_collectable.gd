extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite3D.hide()
	%Fork.texture = ForkCollectableVisual.get_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("snap_to_edge"):
		%AudioStreamPlayer3D.play()
		$GPUParticles3D.emitting = true
		%Fork.visible = false
		%Area3D.monitoring = false


func _on_gpu_particles_3d_finished() -> void:
	queue_free()
