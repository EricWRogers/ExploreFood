extends Area3D

@export var spawn: Node3D
@export var spawn_points : Array[Marker3D] = []
@export var player = null

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var closest_spawn = get_closest_spawn_point(body.global_position)
		
		if closest_spawn:
			print("the closest spawn: ", closest_spawn.name)
			body.global_position = closest_spawn.global_position
		#player.body
		#body.global_position = spawn.global_position

func get_closest_spawn_point(target_position: Vector3) -> Node3D:
	var closest_node: Node3D = null
	var shortest_distance: float = INF
	
	for spawn in spawn_points:
		if spawn:
			var distance = target_position.distance_squared_to(spawn.global_position)
			#var distance = spawn_points.global_position - body.global_position
			
			if distance < shortest_distance:
				shortest_distance = distance
				closest_node = spawn
	return closest_node
