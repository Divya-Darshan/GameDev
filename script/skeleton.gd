extends CharacterBody2D

var speed = 40
var stop_distance = 15  # Slightly increased stop distance
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
	if health == 0:
		health=100 # respawn the eny after death
		alive = false
		sprite.play("death")
		await sprite.animation_finished  # Wait for death animation to finish
		sprite.frame = sprite.sprite_frames.get_frame_count("death") - 1 
		await get_tree().create_timer(5).timeout
		fade_out_and_free()

	if ply_inchase and player:
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
	if body.has_method('player'):
		sprite.play("walk")
		await get_tree().create_timer(0.3).timeout
	player = body
	ply_inchase = true

func _on_range_body_exited(body: Node2D) -> void:
	player = null
	ply_inchase = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method('player'):
		sprite.play("ack1")
		await get_tree().create_timer(0.3).timeout
		player_inrange = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method('player'):
		sprite.play("walk")
		await get_tree().create_timer(0.3).timeout
		player_inrange = false 

func ply_ack():
	if can_attack and health > 0:
		if player_inrange:
			print("eny get damage from ply💥💥")
			health -= 10
			sprite.play("gethit")
			await get_tree().create_timer(0.2).timeout
			can_attack = false
			await get_tree().create_timer(ack_cooldown).timeout
			can_attack = true
			sprite.play("ack1")
			await get_tree().create_timer(0.3).timeout
