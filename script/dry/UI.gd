extends Control

@onready var player = get_node("../../../Knight")

func _on_t_pressed() -> void:
	player.handle_touch_input("t")


func _on_b_pressed() -> void:
	player.handle_touch_input("b")


func _on_o_pressed() -> void:
	player.handle_touch_input("o")


func _on_x_pressed() -> void:
	player.handle_touch_input("x")
