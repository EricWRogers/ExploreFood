extends Node3D

@export var recipe: Resource
@export var rotation_duration: float = 2.0
@export var bob_height: float = 0.2
@export var bob_duration: float = 1.0

func _ready() -> void:
	$Sprite3D.texture = recipe.recipe_icon
	print($Sprite3D.texture)

	_start_rotation()
	_start_bobbing()


func _start_rotation() -> void:
	var tween = create_tween().set_loops()

	tween.tween_property(
		self,
		"rotation:y",
		rotation.y + TAU,
		rotation_duration
	).from_current().set_trans(Tween.TRANS_LINEAR)
	
	
func _start_bobbing() -> void:
	var tween = create_tween().set_loops()

	tween.tween_property(
		self,
		"position:y",
		position.y + bob_height,
		bob_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"position:y",
		position.y,
		bob_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Manager.player_unlocked_recipes.append(recipe)
		queue_free()
