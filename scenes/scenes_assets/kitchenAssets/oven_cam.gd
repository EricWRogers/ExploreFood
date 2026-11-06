@tool
extends PhantomCamera3D

func _ready():
	pass
func make_active()->void:
  var priority : int = get_pcam_host_owner().get_active_pcam().get_priority() + 1
  set_priority(priority)
