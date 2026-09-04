extends CharacterBody2D

const speed = 1200

var start_point = Vector2()
var end_point = Vector2()

#time for slam
var time = 0
var timeDirection = 1
var moveDuration = 0.4

func _ready():
	var screenSize = get_viewport().get_visible_rect().size
	start_point = Vector2(position.x, position.y) #set start point
	end_point = Vector2(position.x, screenSize.y * 0.6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	#var left = Input.is_action_pressed("ui_left")
	#var right = Input.is_action_pressed("ui_right")
	
	if Input.is_action_pressed("Left"):
		velocity.x = -speed
	elif Input.is_action_pressed("Right"):
		velocity.x = speed
	elif Input.is_action_pressed("Back"): #needs more tweeking
		#smash the fist down
		if(time > moveDuration or time < 0):
			timeDirection *= -1
		time += delta * timeDirection
		var t = time / moveDuration
		position = lerp(start_point, end_point, t)
	else:
		velocity.x = 0
		#velocity.x += speed * delta #fun
	#no vertical movement just left and right
	
	move_and_slide()
	
