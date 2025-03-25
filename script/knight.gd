extends "res://script/dry/BaseCharacter.gd"

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


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name, "Type:", body.get_class())  # Print the type of the body
	if body.has_method("take_damage"):  # Check if the body has the 'take_damage' method
		body.take_damage(10)  # Apply damage
		print("💥 Enemy hit!")
