extends Node

@export var lines: Array[String] = []
@export var position: Vector3

#have script on NPC
#NPC should have e to interact label as a child

func _unhandled_input(event):
	if event.is_action_pressed("Interact"):
		if lines.size() > 0: #change this to an area detection
			pass
			#hide interaction label
			DialogueManager.start_dialogue(position, lines)


func _on_interact_area_body_entered(body):
	pass
	#if body is part of group player
		#show interaction label

func _on_interact_area_body_exited(body):
	pass
	#if body is part of group player
		#hide interaction label
	
