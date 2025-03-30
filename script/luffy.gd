extends CharacterBody2D

var speed = 300
var last_direction = Vector2.RIGHT
var is_attacking = false
var state
var attack_speed_multiplier = 0.10 

@onready var sprite = $AnimatedSprite2D


func _physics_process(delta):
	# Get movement input
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Update last known direction if joystick is moved.
	if dir != Vector2.ZERO:
		last_direction = dir.normalized()
	
	# Determine state for animations (only when not attacking)
	if not is_attacking:
		if dir == Vector2.ZERO:
			state = "idle"
		else:
			state = "walk"
	
	# Adjust speed if attacking
	var current_speed = speed * (attack_speed_multiplier if is_attacking else 1)
	velocity = dir * current_speed
	move_and_slide()
	
	# Only update movement animations if not attacking.
	if not is_attacking:
		play_anime(dir)

func play_anime(d):
	if state == "idle":
		sprite.play("idle")
	elif state == "walk":
		# Adjust horizontal flip based on direction.
		if abs(d.x) > abs(d.y):
			sprite.flip_h = d.x < 0
		sprite.play("walk")

func _on_animation_finished():
	# Check if the finished animation was one of the attack animations.
	if sprite.animation in ["attack", "attack2", "attack1"]:
		is_attacking = false
		sprite.play("idle")
	
