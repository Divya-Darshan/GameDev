extends Node

var websocket := WebSocketPeer.new()
var url := "wss://gamedev-ws.onrender.com"
var _connected := false
@onready var label: Label = $CanvasLayer/Label



func _ready():
	print("🔌 Connecting to WebSocket server...")
	var err := websocket.connect_to_url(url)
	if err != OK:
		print("❌ Connection failed immediately: ", err)

func _process(_delta):
	websocket.poll()
	var state := websocket.get_ready_state()

	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass
		WebSocketPeer.STATE_OPEN:
			if not _connected:
				print("✅ Connected to WebSocket server!")
				_connected = true

			while websocket.get_available_packet_count() > 0:
				var packet := websocket.get_packet()
				var msg := packet.get_string_from_utf8()
				print("📨 Server says:", msg)
				label.text =  msg
		WebSocketPeer.STATE_CLOSING:
			print("⚠️ Connection is closing...")
		WebSocketPeer.STATE_CLOSED:
			if _connected:
				print("❌ Disconnected from WebSocket server")
				_connected = false

	if Input.is_action_just_pressed("send_msg"):
		send_message("📲 Touch button message!")

func send_message(message: String):
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		websocket.send_text(message)
		print("📤 Sent:", message)
		label.text = message
		await get_tree().create_timer(2.0).timeout
		


	else:
		print("⚠️ Cannot send: Not connected")

func _exit_tree():
	# Gracefully close the WebSocket connection on game exit
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		print("🚪 Closing WebSocket connection...")
		websocket.close()
