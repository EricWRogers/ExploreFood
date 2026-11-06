extends Node

var oven_cam
var player_cam
var collect_cam

func _activate(name):
	reset()
	match name:
		"PlayerCam":
			player_cam.priority = 1
		"OvenCam":
			oven_cam.priority = 1
		"CollectCam":
			collect_cam.priority = 1

func reset():
	oven_cam.priority = 0
	player_cam.priority = 0
	collect_cam.priority = 0

func switch_to_regular(): _activate("PlayerCam")
func switch_to_oven(): _activate("OvenCam")
func switch_to_collect(): _activate("CollectCam")
