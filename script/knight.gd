extends "res://script/dry/BaseCharacter.gd"

@onready var touch_button = $"../btn/HBoxContainer/Control/t"

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
func  player():
	pass


func _on_hitbox_body_entered(body: Node2D) -> void:
	print(body.name) # Print the type of the body
	if body.has_method("take_damage"):  # Check if the body has the 'take_damage' method
		#if touch_button.is_pressed():
			print(touch_button.is_pressed())
			body.take_damage(10)  # Apply damage
			print("💥 Enemy hit!")
		
