extends CharacterBody2D

var speed = 300
var state = "idle"
var is_attacking = false
var attack_speed_multiplier = 0.10  # Movement is slower while attacking
var last_direction = Vector2.RIGHT
 # Attack animation names

@onready var sprite = $AnimatedSprite2D  # Reference to AnimatedSprite2D
@onready var marker = $Marker2D
@onready var t_btn = null
@onready var b_btn = null  # TouchScreenButton reference
@onready var o_btn = null
@onready var x_btn = null

var reset_timer: Timer

func _ready():
	# Find the attack button in the scene
	t_btn = get_node_or_null("../btn/HBoxContainer/t")
	b_btn = get_node_or_null("../btn/HBoxContainer/b")
	o_btn = get_node_or_null("../btn/HBoxContainer/o")
	x_btn = get_node_or_null("../btn/HBoxContainer/x")
	
	# Ensure that the button signal is connected when the character is loaded
	if t_btn and not t_btn.pressed.is_connected(_on_t_pressed):
		t_btn.pressed.connect(_on_t_pressed)
	if b_btn and not b_btn.pressed.is_connected(_on_t_pressed):
		b_btn.pressed.connect(_on_t_pressed)
	if o_btn and not o_btn.pressed.is_connected(_on_t_pressed):
		o_btn.pressed.connect(_on_t_pressed)
	if x_btn and not x_btn.pressed.is_connected(_on_t_pressed):
		x_btn.pressed.connect(_on_t_pressed)

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
	
	# Adjust speed if attacking (prevents movement during attack)
	var current_speed = 0 if is_attacking else speed  
	velocity = dir * current_speed
	move_and_slide()
	
	# Update movement animations properly
	update_state(dir)
	update_animation(dir)

func update_state(dir):
	if is_attacking:
		state = "attack"  # If attacking, set state to attack (ensures no conflicting animations)
	elif dir == Vector2.ZERO:
		state = "idle"
	else:
		state = "walk"

func update_animation(dir):
	# Play the correct animation based on movement state
	if state == "idle":
		sprite.play("idle")
	elif state == "walk":
		if abs(dir.x) > abs(dir.y):
			sprite.flip_h = dir.x < 0
		sprite.play("walk")

func _on_animation_finished():
	# Check if the finished animation was one of the attack animations.
	if sprite.animation:
		is_attacking = false  # Allow movement again
		update_state(Vector2.ZERO)  # Reset to idle state
		update_animation(Vector2.ZERO)  # Ensure correct animation plays

func _on_t_pressed() -> void:
	if is_attacking:
		return
	is_attacking = true
	sprite.play('ack1')  # Play random attack animation
	
	# Flip attack animation based on last movement direction
	if last_direction.x != 0:
		sprite.flip_h = last_direction.x < 0


func _on_b_pressed() -> void:
	if is_attacking:
		return
	is_attacking = true
	sprite.play('ack2')  # Play random attack animation
	
	# Flip attack animation based on last movement direction
	if last_direction.x != 0:
		sprite.flip_h = last_direction.x < 0
