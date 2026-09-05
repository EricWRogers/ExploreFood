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
		emit_signal("level_changed", level_name)
		
func switch():
	emit_signal("level_changed", level_name)

func _on_spawn_npc_timeout() -> void:
	if Manager.bagel_mode:
		$CalebModeShield.hide()
	if npc_spawn_tick < npc_spawn_cap:
		npc_spawn_tick += 1
		$SpawnNPC.wait_time = randi_range(2, 4)
		var npc = NPC_BAGEL.instantiate()
		$NPCTrailOfBagels.add_child(npc)
		npc.global_position = $NPCTrailOfBagels.global_position
	else:
		$SpawnNPC.one_shot = true
		$SpawnNPC.stop()
