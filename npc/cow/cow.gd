extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Sprite2D = $Shadow

const SPEED := 30.0

var state_time := 0.0
var state_duration := 0.0
var current_state := "idle"  # idle, walk, eat
var direction := Vector2.ZERO

func _ready() -> void:
	randomize()
	_set_new_state()

func _process(delta: float) -> void:
	state_time += delta

	# Check if it's time to switch state
	if state_time >= state_duration:
		_set_new_state()

	match current_state:
		"idle":
			animated_sprite_2d.play("idle")
			velocity = Vector2.ZERO
			shadow.visible = true

		"eat":
			animated_sprite_2d.play("eat")
			velocity = Vector2.ZERO
			shadow.visible = true

		"walk":
			velocity = direction * SPEED
			if velocity.length() > 1.0:
				_play_walk_animation()
			else:
				animated_sprite_2d.play("idle")
				shadow.visible = true

	move_and_slide()


func _set_new_state() -> void:
	state_time = 0.0

	# First choose the new state
	var states = ["idle", "walk", "eat"]
	current_state = states[randi() % states.size()]

	# Then assign the correct duration
	match current_state:
		"idle":
			state_duration = randf_range(1.5, 4.0)
		"eat":
			state_duration = randf_range(2.0, 5.0)
		"walk":
			state_duration = randf_range(2.5, 6.0)

	# If walking, pick a direction
	if current_state == "walk":
		var dirs = [
			Vector2.LEFT, Vector2.RIGHT,
			Vector2.UP, Vector2.DOWN
		]
		direction = dirs[randi() % dirs.size()]
		var jitter = Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))
		direction = (direction + jitter).normalized()
	else:
		direction = Vector2.ZERO


func _play_walk_animation() -> void:
	if direction.y < -0.5:
		# Walking UP
		animated_sprite_2d.play("up")
		shadow.visible = false

	elif direction.y > 0.5:
		# Walking DOWN
		animated_sprite_2d.play("down")
		shadow.visible = false

	else:
		# Walking SIDEWAYS
		if animated_sprite_2d.sprite_frames.has_animation("side"):
			animated_sprite_2d.play("side")
		else:
			animated_sprite_2d.play("idle") # fallback
		animated_sprite_2d.flip_h = direction.x < 0
		shadow.visible = true
