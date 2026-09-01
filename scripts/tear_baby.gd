extends BaseFood
@export var handheld : bool = false


func on_looked_at():
	if handheld:
		return
	else:
		super()
		
func on_looked_away():
	if handheld:
		return
	else:
		super()
		
func get_took():
	if handheld:
		return
	else:
		super()
	
func get_rolled():
	if handheld:
		return
	else:
		super()
