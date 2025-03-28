extends "res://script/dry/BaseCharacter.gd"

@onready var touch_button = get_node("../btn/HBoxContainer/Control/t")
@onready var button_handler = get_node("../btn/HBoxContainer/Control")  # Ensure this path is correct

func handle_touch_input(action: String):
	match action:
		"t":
			attack("atk1")  # Attack 1
		"b":
			attack("atk2")  # Attack 2
		"x":
			pass # 
		"o":
			pass 

func player():
	pass # This function checks whether the body is a player or any other entity 

func _on_hitbox_body_entered(body: Node2D) -> void:
	print(body.name)
	print(button_handler.t_state)
	if not button_handler or not body.has_method("take_damage"):
		return  # Ensure button handler exists and enemy has take_damage method

	if button_handler.t_state:
		print("✅ Button state active, attacking enemy!")
		body.take_damage(10)  # Apply damage to enemy
		print("💥 Enemy hit!")


func _on_hitbox_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
