extends CharacterBody2D

var speed = 40
var stop_distance = 10  # Slightly increased stop distance
var ply_inchase = false
var player = null


var ack_cooldown = 0.3

var health = 100
var alive = true
var player_inrange = false
var can_attack = true

@onready var t_btn = null
@onready var b_btn = null  # TouchScreenButton reference
@onready var o_btn = null
@onready var x_btn = null

@onready var sprite = $AnimatedSprite2D

var is_dead = false  # New flag to track if the enemy is dead

func _ready() -> void:
	t_btn = get_node_or_null("../btn/HBoxContainer/t")
	b_btn = get_node_or_null("../btn/HBoxContainer/b")
	o_btn = get_node_or_null("../btn/HBoxContainer/o")
	x_btn = get_node_or_null("../btn/HBoxContainer/x")
	
	# Ensure that each button signal is connected correctly
	if t_btn and not t_btn.pressed.is_connected(_on_t_pressed):
		t_btn.pressed.connect(_on_t_pressed)
	if b_btn and not b_btn.pressed.is_connected(_on_b_pressed):
		b_btn.pressed.connect(_on_b_pressed)  # Corrected function name
	#if o_btn and not o_btn.pressed.is_connected(_on_o_pressed):
		#o_btn.pressed.connect(_on_o_pressed)  # Corrected function name
	#if x_btn and not x_btn.pressed.is_connected(_on_x_pressed):
		#x_btn.pressed.connect(_on_x_pressed) 

func _on_t_pressed() -> void:
	ply_ack()
	
func _on_b_pressed() -> void:
	ply_ack()

func _physics_process(delta: float) -> void:
	# Check if the enemy is dead, and stop processing if true
	if is_dead:
		return  # Exit early, do nothing if the enemy is dead

	# Handle death logic if health is zero
	if health <= 0 and not is_dead:
		is_dead = true  # Mark the enemy as dead
		sprite.play("death")
		await sprite.animation_finished  # Wait for the death animation to finish
		await get_tree().create_timer(0.9).timeout  # Delay for the animation
		fade_out_and_free()

	# Movement and chase logic only happens if the enemy is alive
	if ply_inchase and player and alive:
		var direction = (player.position - position).normalized()
		var distance = player.position.distance_to(position)

		if distance > stop_distance:
			if sprite.animation != "ack1":
				sprite.play("walk")
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO  # Stop instead of reversing

		sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		if sprite.animation != "ack1":
			sprite.play("idle")

	move_and_collide(velocity * delta)  # Use precise collision movement

func eny():
	pass

func fade_out_and_free():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 1.0)  # Fade out over 1 second
	await tween.finished
	queue_free()

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method('player') and not is_dead:  # Check if dead
		sprite.play("walk")
		await get_tree().create_timer(0.3).timeout
	player = body
	ply_inchase = true

func _on_range_body_exited(body: Node2D) -> void:
	if not is_dead:  # Only process if alive
		player = null
		ply_inchase = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method('player') and not is_dead:  # Check if dead
		sprite.play("ack1")
		await get_tree().create_timer(0.3).timeout
		player_inrange = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method('player') and not is_dead:  # Check if dead
		sprite.play("walk")
		await get_tree().create_timer(0.3).timeout
		player_inrange = false 

func ply_ack():
	if can_attack and health > 0 and not is_dead:  # Don't process attack if dead
		if player_inrange:
			print("enemy gets damage from ply💥💥")
			health -= 10
			sprite.play("gethit")

			# Check if health is zero or less and exit if true
			if health <= 0:
				print("Enemy health is 0, exiting function.")
				return  # Exits the function if health is 0 or lower

			# Otherwise continue with the attack logic
			await get_tree().create_timer(0.2).timeout
			can_attack = false
			await get_tree().create_timer(ack_cooldown).timeout
			can_attack = true
			sprite.play("ack1")
			await get_tree().create_timer(0.3).timeout 
