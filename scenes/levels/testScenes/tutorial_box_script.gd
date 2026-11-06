extends Control

var holding

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var timer:Timer = Timer.new()  #Create a timer, it will loop by default   
	timer.wait_time = 0.1 
	add_child(timer)
	if holding:
		timer.start()  #Make it start ticking  
		#print(timer)
	else:
		timer.stop() #Make it stop ticking

#make box visible
func show_tutorial_text():
	$".".show()
	
#make box invisible
func hide_tutorial_text():
	$".".hide()

#when pressing close button
func close_button():
	hide_tutorial_text()
	#print("pressed")
	
#when holding close button
func button_being_held():
	holding = true
	#print("hold")
	
func button_not_held():
	holding = false
	#print(" not hold")
	
func _process(_delta):

	if holding:
		$"hold button/ProgressBar".value += 0.75
		print($"hold button/ProgressBar".value)
	elif !holding:
		$"hold button/ProgressBar".value = 0
	#elif holding and completed:
		#print("done")
		#pass

	if $"hold button/ProgressBar".value == 100:
		#print("Completed interacting!")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hide_tutorial_text()
	
