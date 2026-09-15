extends RigidBody3D

var my_assembler : StaticBody3D
var held = false
var exploded = false
var value = 0
var holder
var ids = []

func sandbot():
	get_tree().call_group("SandwichPiece", "explode", self)
	queue_free()

func on_picked():
	self.set_collision_layer_value(1, false)
	self.set_collision_mask_value(1, false)
	ids.sort()
	if Manager.held_sandwich:
		return
	holder = Manager.player_hold
	Manager.held_sandwich = self
	my_assembler.held_sandwich = null
	my_assembler = null
	held = true
	await get_tree().create_timer(0.1).timeout
	$RayCast3D.enabled = true
	
func _physics_process(delta: float) -> void:
	if !exploded:
		if $RayCast3D.is_colliding():
			var body = $RayCast3D.get_collider()
			if body.get_collision_layer_value(11):
				return
				exploded = true
			exploded = true
			get_tree().call_group("SandwichPiece", "explode", self)
			queue_free()
	if !held:
		return
	var tween = create_tween()
	if is_instance_valid(holder):
		tween.tween_property(self, "global_position", holder.global_position, 0.001)
	
func get_rolled():
	pass
	
func make_inactive():
	self.set_collision_layer_value(1, false)
	self.set_collision_mask_value(1, false)
	self.set_collision_layer_value(12, false)
	self.set_collision_mask_value(12, false)
	$RayCast3D.enabled = false
