extends AudioStreamPlayer3D

func _play_footstep(snd):
	if snd == null:
		self.stop()
		return
	self.stream = snd
	self.play()
	
