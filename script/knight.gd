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
