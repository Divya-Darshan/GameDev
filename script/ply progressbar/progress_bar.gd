extends TextureProgressBar

@onready var player = get_node("../..")  # Adjust path if needed
@onready var tween = get_tree().create_tween()

func _ready():
	max_value = 100
	min_value = 0

	# Connect to player's health change signal
	if player and player.has_signal("helchg"):
		player.helchg.connect(self.update)

	update()  # Initialize visual

func update():
	if not player:
		return

	var target_value = clamp(player.health, min_value, max_value)

	# Kill any running tween before starting a new one
	if tween.is_valid():
		tween.kill()

	# Create a smooth transition
	tween = get_tree().create_tween()
	tween.tween_property(self, "value", target_value, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
