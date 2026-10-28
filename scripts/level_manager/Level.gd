extends Node

const NPC_BAGEL = preload("uid://3v4r25oasxwu")
@export var npc_spawn_cap = 10
var npc_spawn_tick = 0

func _ready() -> void:
	pass

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
