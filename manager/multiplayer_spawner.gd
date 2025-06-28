extends MultiplayerSpawner

func _spawn_player(data):
	var player_id = data[0]
	var spawn_point = data[1]

	print("🔁 Spawning player", player_id, "at", spawn_point)

	var scene = preload("res://char scene/sem/sem.tscn")
	var pl = scene.instantiate()
	pl.name = str(player_id)
	pl.player_id = player_id
	pl.spawn_point = spawn_point
	pl.setup(spawn_point)

	var players_node = get_tree().current_scene.get_node("players")
	if players_node:
		players_node.add_child(pl, true)
	else:
		push_error("❌ No 'players' node found — make sure it exists in Main scene")
