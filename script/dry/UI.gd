extends Control

@onready var player = get_node("../../../Knight")

var t_state = false
var b_state = false
var o_state = false
var x_state = false


func _on_t_pressed() -> void:
	player.handle_touch_input("t")
	t_state = true
	print("✅ Button Pressed!")
	

func _on_t_released() -> void:
	print("❌ Button released!")
	t_state = false

func _on_b_pressed() -> void:
	player.handle_touch_input("b")
	b_state = true


func _on_o_pressed() -> void:
	player.handle_touch_input("o")
	o_state = true

func _on_x_pressed() -> void:
	player.handle_touch_input("x")
	x_state = true
