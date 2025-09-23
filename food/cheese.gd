extends Sprite2D

@onready var parmassan_green: Sprite2D = $ParmassanGreen
@onready var expo: AnimatedSprite2D = $expo

func _ready() -> void:
	# Hide initially
	parmassan_green.visible = false
	expo.visible = false
	
	# Start a 5-minute timer
	var timer := get_tree().create_timer(100.0) # 300 seconds = 5 minutes
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if not is_inside_tree():
		return

	# 50% chance to explode
	if randi() % 2 == 0:
		expo.visible = true
		expo.play()
	else:
		parmassan_green.visible = true

func _on_expo_animation_finished() -> void:
	queue_free()
