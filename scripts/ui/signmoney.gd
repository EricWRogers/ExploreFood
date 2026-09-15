extends Node3D

@export var title : String
@export var cost : int
var total_put_in = 0
var bar_value = 0
var purchased_amount = false
signal purchased

@onready var cost_label: Label3D = $Moneysignage/Cost
@onready var title_label: Label3D = $Moneysignage/Title
@onready var texture_progress_bar: ProgressBar = $Moneysignage/SubViewport/TextureProgressBar

func _ready() -> void:
	title_label.text = title
	cost_label.text = str("$",total_put_in,"/","$",cost)

func update_total():
	bar_value = (float(total_put_in) / cost) * 100.0
	texture_progress_bar.value = bar_value
	cost_label.text = str("$",total_put_in,"/","$",cost)
	print(texture_progress_bar.value)
	if total_put_in >= cost:
		purchase()
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if purchased_amount:
		return
	if body.has_method("absorb"):
		if body.type == "coin":
			total_put_in += 1
			body.absorb()
			update_total()
		else:
			if body.value <= cost:
				total_put_in += body.value
				body.absorb()
				update_total()
			else:
				#purchase()
				purchased_amount = true
				body.value -= cost
				body.update_price()
				total_put_in += body.value
				purchase()
				update_total()
func purchase():
	$AnimationPlayer.play("Bought")
	emit_signal("purchased")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Bought":
		queue_free()
