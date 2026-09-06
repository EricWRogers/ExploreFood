extends Node3D

var moving = false
var hold_setter = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
			Manager.recipe_book.unlock_icons("terry")
			Manager.recipe_book.items["ingredients"]["terry"]["unlocked"] = true
		2:
			$Skeleton3D/BoneAttachment3D/Waffle.show()
			Manager.recipe_book.unlock_icons("waffle")
			Manager.recipe_book.items["ingredients"]["waffle"]["unlocked"] = true
		3:
			$Skeleton3D/BoneAttachment3D/Frogbutt.show()
			Manager.recipe_book.unlock_icons("butter")
			Manager.recipe_book.items["ingredients"]["butter"]["unlocked"] = true
		4:
			$Skeleton3D/BoneAttachment3D/WafflesChicken.show()
			Manager.recipe_book.unlock_icons("chknandwaffles")
			Manager.recipe_book.items["ingredients"]["chknandwaffles"]["unlocked"] = true
		5:
			$Skeleton3D/BoneAttachment3D/Bebeh.show()
			Manager.recipe_book.unlock_icons("babytear")
			Manager.recipe_book.items["ingredients"]["babytear"]["unlocked"] = true
		6:
			$Skeleton3D/BoneAttachment3D/MeatPockets.show()
			Manager.recipe_book.unlock_icons("meatpocket")
			Manager.recipe_book.items["ingredients"]["meatpocket"]["unlocked"] = true
		7:
			$Skeleton3D/BoneAttachment3D/DoughBebeh.show()
			Manager.recipe_book.unlock_icons("doughbaby")
			Manager.recipe_book.items["ingredients"]["doughbaby"]["unlocked"] = true
		8:
			$Skeleton3D/BoneAttachment3D/MeatBall.show()
			Manager.recipe_book.unlock_icons("meatball")
			Manager.recipe_book.items["ingredients"]["meatball"]["unlocked"] = true
		9:
			pass
		
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
