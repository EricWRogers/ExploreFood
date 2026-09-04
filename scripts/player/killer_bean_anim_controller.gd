extends Node3D

var moving = false
var hold_setter = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_anims():
	#print(str(Manager.holding, ": manager holding"))
	#print(str(hold_setter, ": hold setter"))
	#print(str(moving, ": moving"))
	if Manager.holding == true:
		if hold_setter == false:
			hold_setter = true
			hold()
		return
	hold_setter = false
	if moving == true:
		run()
	else:
		idle()
		
func update_held_item(id):
	reset_held()
	match id:
		0:
			reset_held()
		1:
			$Skeleton3D/BoneAttachment3D/Terry.show()
		2:
			$Skeleton3D/BoneAttachment3D/Waffle.show()
		3:
			$Skeleton3D/BoneAttachment3D/Frogbutt.show()
		4:
			$Skeleton3D/BoneAttachment3D/WafflesChicken.show()
		5:
			$Skeleton3D/BoneAttachment3D/Bebeh.show()
		6:
			$Skeleton3D/BoneAttachment3D/MeatPockets.show()
		7:
			$Skeleton3D/BoneAttachment3D/DoughBebeh.show()
		8:
			$Skeleton3D/BoneAttachment3D/MeatBall.show()
		
func reset_held():
	$Skeleton3D/BoneAttachment3D/Frogbutt.hide()
	$Skeleton3D/BoneAttachment3D/Terry.hide()
	$Skeleton3D/BoneAttachment3D/Waffle.hide()
	$Skeleton3D/BoneAttachment3D/WafflesChicken.hide()
	$Skeleton3D/BoneAttachment3D/Bebeh.hide()
	$Skeleton3D/BoneAttachment3D/MeatPockets.hide()
	$Skeleton3D/BoneAttachment3D/DoughBebeh.hide()
	$Skeleton3D/BoneAttachment3D/MeatBall.hide()

func hold():
	$AnimationPlayer.play("Hold")
func run():
	$AnimationPlayer.play("Run")
func idle():
	$AnimationPlayer.play("Hold")
	$AnimationPlayer.stop()
