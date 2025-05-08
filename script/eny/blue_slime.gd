extends CharacterBody2D

signal enyhelchg

var speed := 40
var stop_distance := 5
var ack_cooldown := 0.5

var health := 100
var currenthealth := 100
var alive := true
var is_dead := false  # <-- Added for safe despawn handling
var can_attack := true
var player_inrange := false
var ply_inchase := false
var player = null

var bar_tween: Tween  # Tween for smooth health bar transitions

@onready var t_btn = get_node_or_null("../btn/HBoxContainer/t")
@onready var b_btn = get_node_or_null("../btn/HBoxContainer/b")
@onready var o_btn = get_node_or_null("../btn/HBoxContainer/o")
@onready var x_btn = get_node_or_null("../btn/HBoxContainer/x")
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $TextureProgressBar

func _ready() -> void:
	if t_btn and not t_btn.pressed.is_connected(_on_t_pressed):
		t_btn.pressed.connect(_on_t_pressed)
	if b_btn and not b_btn.pressed.is_connected(_on_b_pressed):
		b_btn.pressed.connect(_on_b_pressed)

	# Health bar starts hidden and transparent
	health_bar.visible = false
	health_bar.modulate.a = 0

func eny():
	pass

func _physics_process(delta: float) -> void:
	if not alive:
		return

	if currenthealth <= 0:
		die()
		return

	if ply_inchase and player:
		var direction = (player.position - position).normalized()
		var distance = player.position.distance_to(position)

		if distance > stop_distance:
			if sprite.animation != "ack1":
				sprite.play("ack1")
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	sprite.flip_h = player and player.position.x < position.x
	move_and_collide(velocity * delta)

func die():
	if is_dead:
		return  # Prevent multiple death calls

	is_dead = true
	alive = false
	sprite.play("death")
	await sprite.animation_finished

	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	queue_free()

func _on_t_pressed() -> void:
	ply_ack()

func _on_b_pressed() -> void:
	ply_ack()

func ply_ack():
	if can_attack and alive and player_inrange:
		print("player Enemy took damage")
		currenthealth -= 10
		currenthealth = max(0, currenthealth)
		enyhelchg.emit()

		if currenthealth <= 0:
			die()
			return

		can_attack = false
		await get_tree().create_timer(ack_cooldown).timeout
		can_attack = true

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		ply_inchase = true
		smooth_show_healthbar(true)

func _on_range_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		ply_inchase = false
		smooth_show_healthbar(false)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inrange = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inrange = false

func smooth_show_healthbar(show: bool) -> void:
	if show and not health_bar.visible:
		health_bar.visible = true
		health_bar.modulate.a = 0

	if bar_tween and bar_tween.is_valid():
		bar_tween.kill()

	bar_tween = get_tree().create_tween()

	var target_alpha = 1.0 if show else 0.0

	bar_tween.tween_property(
		health_bar,
		"modulate:a",
		target_alpha,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if not show:
		bar_tween.tween_callback(func(): health_bar.visible = false)
