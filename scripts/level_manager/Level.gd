extends Node

const NPC_BAGEL = preload("uid://3v4r25oasxwu")
@export var npc_spawn_cap = 10
var npc_spawn_tick = 0

@export var level_name : String = "level"
signal level_changed(level_name)

func _ready() -> void:
	pass

func _on_portal_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Manager.held_sandwich = null
		
		print("LEVEL NAME: ", level_name)
		emit_signal("level_changed", level_name) #emits signal to level manager

#this sucks im sorry.
func _on_portal_2_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Manager.held_sandwich = null
		
		if (Manager.sandwich_mode):
			level_name = "kitchen2"
		elif (!Manager.sandwich_mode):
			level_name = "diner2"
			
		print("LEVEL NAME: ", level_name)
		emit_signal("level_changed", level_name) #emits signal to level manager

func switch():
	emit_signal("level_changed", level_name) #emits signal to level manager

func _on_spawn_npc_timeout() -> void:
	if Manager.current_customers < npc_spawn_cap:
		Manager.current_customers += 1
		$SpawnNPC.wait_time = randi_range(2, 4)
		var npc = NPC_BAGEL.instantiate()
		$NPCTrailOfBagels.add_child(npc)
		npc.global_position = $NPCTrailOfBagels.global_position
	else:
		pass
		#$SpawnNPC.one_shot = true
		#$SpawnNPC.stop()
