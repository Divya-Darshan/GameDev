extends TextureProgressBar

@onready var enemy = $".."
@onready var tween := create_tween()

func _ready():
	min_value = 0
	max_value = 100

	if enemy:
		enemy.enyhelchg.connect(update_health)
		max_value = enemy.health
		update_health()

func update_health():
	value = clamp(enemy.currenthealth, min_value, max_value)
