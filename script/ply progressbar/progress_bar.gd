extends TextureProgressBar

@onready var player = get_node("../../gojo")  # Adjust this path if needed

func _ready() -> void:
	max_value = 100
	min_value = 0

	if player and player.has_signal("helchg"):
		player.helchg.connect(update)
	
	update()

func update():
	# Safety check: clamp health between 0 and 100
	var percent = clamp((player.health / 100.0) * 100.0, 0, 100)
	value = percent
	print("Health:", player.health, "-> ProgressBar value set to:", value)
