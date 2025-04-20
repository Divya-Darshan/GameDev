extends CharacterBody2D

signal helchg

var health := 100
@onready var currenthealth: int = health
var alive := true
var eny_inrange := false
var can_attack := true

var ack_cooldown := 0.8

var speed := 300
var state := "idle"
var is_attacking := false
var attack_speed_multiplier := 0.10
var last_direction := Vector2.RIGHT

@onready var sprite := $AnimatedSprite2D
@onready var marker := $Marker2D
@onready var t_btn := get_node_or_null("../btn/HBoxContainer/t")
@onready var b_btn := get_node_or_null("../btn/HBoxContainer/b")
@onready var o_btn := get_node_or_null("../btn/HBoxContainer/o")
@onready var x_btn := get_node_or_null("../btn/HBoxContainer/x")

var reset_timer := Timer.new()
var last_gethit_health: int = health


func player():
	pass


func _ready():
	randomize()

	if t_btn and not t_btn.pressed.is_connected(_on_t_pressed):
		t_btn.pressed.connect(_on_t_pressed)
	if b_btn and not b_btn.pressed.is_connected(_on_b_pressed):
		b_btn.pressed.connect(_on_b_pressed)
	if o_btn and not o_btn.pressed.is_connected(_on_o_pressed):
		o_btn.pressed.connect(_on_o_pressed)
	if x_btn and not x_btn.pressed.is_connected(_on_x_pressed):
		x_btn.pressed.connect(_on_x_pressed)

	reset_timer.wait_time = 1.0
	reset_timer.one_shot = true
	add_child(reset_timer)

	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	skeleton_ack()

	if health <= 0:
		alive = false
		sprite.play("gethit")
		await sprite.animation_finished
		queue_free()
		return

	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir != Vector2.ZERO:
		last_direction = dir.normalized()

	var current_speed := 0 if is_attacking else speed
	velocity = dir * current_speed
	move_and_slide()

	update_state(dir)
	update_animation(dir)


func update_state(dir):
	state = "attack" if is_attacking else "idle" if dir == Vector2.ZERO else "walk"


func update_animation(dir):
	if state == "idle":
		sprite.play("idle")
	elif state == "walk":
		if abs(dir.x) > abs(dir.y):
			sprite.flip_h = dir.x < 0
		sprite.play("walk")


func _on_animation_finished():
	is_attacking = false
	update_state(Vector2.ZERO)
	update_animation(Vector2.ZERO)


func _on_t_pressed():
	if is_attacking:
		return
	is_attacking = true
	sprite.play("ack1")
	if last_direction.x != 0:
		sprite.flip_h = last_direction.x < 0


func _on_b_pressed():
	if is_attacking:
		return
	is_attacking = true
	sprite.play("ack2")
	if last_direction.x != 0:
		sprite.flip_h = last_direction.x < 0


func _on_o_pressed():
	health = 100
	last_gethit_health = health
	print(health)
	helchg.emit()


func _on_x_pressed():
	pass


func _on_hitbox_body_entered(body: Node2D):
	if body.has_method('eny'):
		eny_inrange = true


func _on_hitbox_body_exited(body: Node2D):
	if body.has_method('eny'):
		eny_inrange = false


func play_gethit_animation() -> void:
	if sprite.animation != "gethit":
		print("Playing gethit animation!")
		sprite.play("gethit")
		await sprite.animation_finished


func skeleton_ack():
	if can_attack and eny_inrange and health > 0:
		health -= 4
		helchg.emit()

		if last_gethit_health - health >= 10:
			last_gethit_health = health
			await play_gethit_animation()

		can_attack = false
		await get_tree().create_timer(ack_cooldown).timeout
		can_attack = true
