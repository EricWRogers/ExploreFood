extends Area3D

@export var image_of_world : Texture
@export var light_color: Color
@export var active : bool = false
@export var in_kitchen = true
@onready var mat = $Portalmesh.get_surface_override_material(0)

func _ready() -> void:
	
	if !active:
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(1, false)
		$Portalmesh.hide()
		$OmniLight3D.hide()
	$OmniLight3D.light_color = light_color
	mat.set_shader_parameter("albedo_texture", image_of_world)

func unlock():
	$AnimationPlayer.play("unlock")


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("im_food"):
		Manager.collected_food.append(body.scene_file_path)
		body.queue_free()
