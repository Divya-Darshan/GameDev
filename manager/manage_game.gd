extends Node

@onready var spawner: MultiplayerSpawner = $"../MultiplayerSpawner"
@onready var host_button: TouchScreenButton = $"../CanvasLayer/ButtonJoinP1"
@onready var join_button: TouchScreenButton = $"../CanvasLayer/ButtonJoinP2"


func _ready():
	host_button.pressed.connect(host_game)
	join_button.pressed.connect(join_game)


func host_game():
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(12345)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		print("🟢 Hosting on port 12345")
		# Server spawns itself immediately
		spawn_player("point1")
	else:
		print("❌ Failed to host server")

func join_game():
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client("127.0.0.1", 12345)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		print("🔵 Joining 127.0.0.1:12345")
	else:
		print("❌ Failed to join server")

# Server spawns players
func spawn_player(spawn_point: String):
	if multiplayer.is_server():
		var player_id = multiplayer.get_unique_id()
		print("✅ Spawning player", player_id, "at", spawn_point)
		spawner.spawn([player_id, spawn_point])
