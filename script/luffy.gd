extends CharacterBody2D

var speed = 300
var state
var is_attacking = false
var attack_speed_multiplier = 0.10  # Movement is slower while attacking
var bow_eq = true
var bow_timer = true
var arrow = preload("res://scene/arrow.tscn")
var last_direction = Vector2.RIGHT

var acck = ["ack2", "ack1"]

@onready var sprite = $AnimatedSprite2D
@onready var marker = $Marker2D

var reset_timer: Timer

func _ready():
	reset_timer = Timer.new()
	reset_timer.wait_time = 1.0  # 1 second delay for bow arrow
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_on_reset_timer_timeout)
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
	if sprite.animation in ["ack1", "ack2", "ack1"]:
		is_attacking = false
		bow_eq = true
		sprite.play("idle")

func _on_arrowbtn_pressed() -> void:
	marker.global_position = global_position
	marker.rotation = last_direction.angle()
	
	if bow_eq and bow_timer:
		bow_timer = false  
		reset_timer.start()    
		
		var arrow_inst = arrow.instantiate()
		arrow_inst.rotation = last_direction.angle()
		arrow_inst.global_position = global_position + Vector2(10, -40)
		add_child(arrow_inst)

func _on_reset_timer_timeout():
	bow_timer = true

func _on_ackbtn_pressed() -> void:

	if is_attacking:
		return
	bow_eq = false
	is_attacking = true
	sprite.play(acck.pick_random())

func _on_ackbtn_released() -> void:
	bow_eq = true 
