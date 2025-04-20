extends CharacterBody2D

signal enyhelchg

var speed = 45
var stop_distance = 10
var ack_cooldown = 0.5

var health := 100
var currenthealth := 100
var alive := true
var can_attack := true
var is_dead := false
var ply_inchase := false
var player_inrange := false
var player = null

@onready var t_btn = get_node_or_null("../btn/HBoxContainer/t")
@onready var b_btn = get_node_or_null("../btn/HBoxContainer/b")
@onready var sprite =$Shadow/AnimatedSprite2D
@onready var health_bar = $TextureProgressBar
@onready var bar_tween = $Tween  # Ensure you have a Tween node under the same parent

func _ready() -> void:
	if t_btn: t_btn.pressed.connect(_on_t_pressed)
	if b_btn: b_btn.pressed.connect(_on_b_pressed)

	# Initial setup for health bar (starts invisible)
	health_bar.visible = false
	health_bar.modulate.a = 0

func eny():
	pass

func _on_t_pressed() -> void:
	ply_ack()

func _on_b_pressed() -> void:
	ply_ack()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if currenthealth <= 0:
		die()
		return

	if ply_inchase and player:
		var direction = (player.position - position).normalized()
		var distance = player.position.distance_to(position)

		if distance > stop_distance:
			if sprite.animation != "ack1":
				sprite.play("walk")
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO

		sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		if sprite.animation != "ack1":
			sprite.play("idle")

	move_and_collide(velocity * delta)

func die():
	is_dead = true
	sprite.play("death")
	await sprite.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	queue_free()

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method('player') and not is_dead:
		player = body
		ply_inchase = true
		sprite.play("walk")

func _on_range_body_exited(body: Node2D) -> void:
	if not is_dead:
		player = null
		ply_inchase = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method('player') :
		player_inrange = true
		sprite.play("ack1")
		smooth_show_healthbar(true)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method('player'):
		player_inrange = false
		sprite.play("walk")
		smooth_show_healthbar(false)

func ply_ack():
	if can_attack and not is_dead and player_inrange:
		print("enemy gets damage from ply💥💥")
		currenthealth -= 10
		enyhelchg.emit()
		sprite.play("gethit")

		if currenthealth <= 0:
			die()
			return
		
		# Smooth transition for getting hit or taking damage
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate:a", 0.5, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		can_attack = false
		await get_tree().create_timer(ack_cooldown).timeout
		can_attack = true
		sprite.play("ack1")

# Function to show/hide health bar smoothly
func smooth_show_healthbar(show: bool) -> void:
	if show and not health_bar.visible:
		health_bar.visible = true
		health_bar.modulate.a = 0  # Start invisible

	if bar_tween and bar_tween.is_valid():
		bar_tween.kill()

	var bar_tween_instance = get_tree().create_tween()

	var target_alpha = 1.0 if show else 0.0

	bar_tween_instance.tween_property(
		health_bar,
		"modulate:a",
		target_alpha,
		0.4  # Fade duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if not show:
		bar_tween_instance.tween_callback(func(): health_bar.visible = false)
