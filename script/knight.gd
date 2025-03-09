extends CharacterBody2D

var speed = 300
var state
var is_attacking = false
var attack_speed_multiplier = 0.10
var ply_health = 100
var ply_alive = true
var en_int = false

@onready var camera = $Camera2D
@onready var settings = $"../ham"
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
#sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)  # Connect signal

func _physics_process(delta):
	# Get movement input
	slime_atk()
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Determine state for animations (only when not attacking)
	if not is_attacking and ply_alive:
		if dir == Vector2.ZERO:
			state = "idle"
		else:
			state = "walk"

	# Adjust speed if attacking
	var current_speed = speed * (attack_speed_multiplier if is_attacking else 1)
	velocity = dir * current_speed
	move_and_slide()

	# Only update movement animations if not attacking.
	if not is_attacking and ply_alive:
		play_anime(dir)

func play_anime(d):
	if state == "idle":
		sprite.play("idle")
	elif state == "walk":
		if abs(d.x) > abs(d.y):
			sprite.flip_h = d.x < 0
		sprite.play("walk")

# Resets attack state when animation finishes
func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "atk1" or sprite.animation == "atk2":
		is_attacking = false
		sprite.play("idle")  # Return to idle animation
	elif sprite.animation == "death":
		self.queue_free()

# Attack function for B button
func _on_b_btn_pressed() -> void:
	if is_attacking or not ply_alive:
		return
	is_attacking = true
	sprite.play("atk2")

# Attack function for T button
func _on_t_btn_pressed() -> void:
	if is_attacking or not ply_alive:
		return
	is_attacking = true
	sprite.play("atk1")


func _on_p_btn_pressed() -> void:
	_on_t_btn_pressed()  # Calls T button function

# Enemy enters hitbox
func _on_pl_hit_body_entered(body: Node2D) -> void:
	if body.has_method("slime"):
		en_int = true



func _on_pl_hit_body_exited(body: Node2D) -> void:
	if body.has_method("slime"):
		en_int = false


func slime_atk():
	if en_int and ply_alive:
		print(ply_health)
		ply_health -= 0.5

		if ply_health <= 0:
			ply_alive = false
			sprite.play("death")
			await sprite.animation_finished  # Wait for death animation
