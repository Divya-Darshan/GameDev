extends Node

@onready var spawnpoint: Node2D = $spawnpoint
@onready var button_join_p_1: TouchScreenButton = $Node/CanvasLayer/ButtonJoinP1
@onready var button_join_p_2: TouchScreenButton = $Node/CanvasLayer/ButtonJoinP2

var websocket := WebSocketPeer.new()
var _connected := false
var url := "wss://gamedev-ws.onrender.com"
var player_scene := preload("res://char scene/sem/sem.tscn")

var local_player: CharacterBody2D = null
var remote_players := {}  # Dictionary of remote players: { "player1": player_node, ... }
var remote_target_positions := {}  # Dictionary of target positions: { "player1": Vector2 }

var last_sent_position := Vector2.INF

func _ready():
	button_join_p_1.pressed.connect(_on_join_p1)
	button_join_p_2.pressed.connect(_on_join_p2)

	var err := websocket.connect_to_url(url)
	if err != OK:
		print("❌ Failed to connect:", err)
	else:
		print("🔌 Connecting to server...")

func _process(_delta):
	websocket.poll()

	# Handle connection open
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		if not _connected:
			print("✅ Connected to WebSocket")
			_connected = true

		while websocket.get_available_packet_count() > 0:
			var msg = websocket.get_packet().get_string_from_utf8()
			_handle_message(msg)

	# Smooth remote players' positions
	for id in remote_players.keys():
		if remote_target_positions.has(id):
			var remote = remote_players[id]
			var target = remote_target_positions[id]
			remote.global_position = remote.global_position.lerp(target, 0.1)

func _physics_process(_delta):
	if _connected and local_player:
		if local_player.global_position != last_sent_position:
			last_sent_position = local_player.global_position
			var pos = str(last_sent_position.x) + "," + str(last_sent_position.y)
			websocket.send_text("move:" + local_player.name + ":" + pos)

func _on_join_p1():
	_spawn_player("player1", "point1")

func _on_join_p2():
	_spawn_player("player2", "point2")

func _spawn_player(id: String, point_name: String):
	local_player = player_scene.instantiate()
	local_player.name = id
	local_player.position = spawnpoint.get_node(point_name).global_position
	add_child(local_player)

	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		websocket.send_text("join:" + id)

func _handle_message(msg: String):
	if msg.begins_with("join:"):
		var id = msg.split(":")[1]
		if id != local_player.name and not remote_players.has(id):
			var remote = player_scene.instantiate()
			remote.name = id
			remote.modulate = Color(1, 0.6, 0.6)  # Tint for remote players
			remote.position = Vector2.ZERO
			add_child(remote)
			remote_players[id] = remote
			remote_target_positions[id] = Vector2.ZERO

	elif msg.begins_with("move:"):
		var parts = msg.split(":")
		if parts.size() == 3:
			var who = parts[1]
			if who != local_player.name:
				var coords = parts[2].split(",")
				if coords.size() == 2:
					var pos = Vector2(coords[0].to_float(), coords[1].to_float())
					if remote_target_positions.has(who):
						remote_target_positions[who] = pos
