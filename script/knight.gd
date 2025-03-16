extends CharacterBody2D

var speed = 300
var is_attacking = false
var attack_speed_multiplier = 0.1
var ply_alive = true

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D  # Reference to the Area2D node

# Connect signals in _ready()
func _ready():
	print("DJFBDBCVD")
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	
func _on_pl_hit_body_entered(body: Node2D) -> void:
	if body:
		print("Body entered:", body.name)
	else:
		print("No body detected in the area.")

# Handle body exiting the area
func _on_pl_hit_body_exited(body: Node2D) -> void:
	if body:
		pass  # You can add logic here for when the body exits the area

# Handle the end of an animation and stop attacking if needed
func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "atk1" or sprite.animation == "atk2":
		is_attacking = false
		sprite.play("idle")

# Process the character's movement and animations
func _physics_process(delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var current_speed = speed * (attack_speed_multiplier if is_attacking else 1)
	velocity = dir * current_speed
	move_and_slide()

	if not is_attacking and ply_alive:
		play_anime(dir)

# Handle animations based on movement
func play_anime(d):

	if d == Vector2.ZERO:
		sprite.play("idle")
	else:
		if abs(d.x) > abs(d.y):
			sprite.flip_h = d.x < 0
		sprite.play("walk")

# Attack Function for B key press
func _on_b_pressed() -> void:
	if is_attacking or not ply_alive:
		return
	is_attacking = true
	sprite.play("atk2")  # Play attack animation for "atk2"

# Attack Function for T key press
func _on_t_pressed() -> void:
	print('fafadfad')
	if is_attacking or not ply_alive:
		return
	is_attacking = true
	sprite.play("atk1")  # Play attack animation for "atk1"
