extends CharacterBody2D

signal enyhelchg

var speed = 40
var stop_distance = 10
var ack_cooldown = 0.8

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
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	if t_btn: t_btn.pressed.connect(_on_t_pressed)
	if b_btn: b_btn.pressed.connect(_on_b_pressed)

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
	await get_tree().create_timer(0.5).timeout  # Optional delay before fading

	# Create a fade-out tween
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
	if body.has_method('player') and not is_dead:
		player_inrange = true
		sprite.play("ack1")

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method('player') and not is_dead:
		player_inrange = false
		sprite.play("walk")

func ply_ack():
	if can_attack and not is_dead and player_inrange:
		print("enemy gets damage from ply💥💥")
		currenthealth -= 10
		enyhelchg.emit()
		sprite.play("gethit")

		if currenthealth <= 0:
			return

		can_attack = false
		await get_tree().create_timer(ack_cooldown).timeout
		can_attack = true
		sprite.play("ack1")
