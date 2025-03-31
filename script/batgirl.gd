extends CharacterBody2D

var speed = 300
var state
var is_attacking = false
var attack_speed_multiplier = 0.10  # Movement is slower while attacking
var last_direction = Vector2.RIGHT

var acck = ["attack2", "attack1"]

@onready var sprite = $AnimatedSprite2D  # Reference to AnimatedSprite2D
@onready var marker = $Marker2D

var reset_timer: Timer

func _ready():
	reset_timer = Timer.new()
	reset_timer.wait_time = 1.0  # 1 second delay for bow arrow
	reset_timer.one_shot = true
	add_child(reset_timer)
	
	# Ensure that animation_finished is connected
	sprite.animation_finished.connect(_on_animation_finished)

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
	if sprite.animation in ["attack2", "attack1"]:
		is_attacking = false
		sprite.play("idle")

func _on_arrowbtn_pressed() -> void:
	marker.global_position = global_position
	marker.rotation = last_direction.angle()
 


func _on_ackbtn_pressed() -> void:
	# If an attack is already in progress, do nothing.
	if is_attacking:
		return
	is_attacking = true
	sprite.play(acck.pick_random())  # Randomly pick an attack animation
