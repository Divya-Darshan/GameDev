extends CharacterBody2D  # Base script for all characters

var speed = 300
var is_attacking = false
var attack_speed_multiplier = 0.1
var ply_alive = true
var ply_health = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area = $Area2D/CollisionShape2D


func _ready(): 
		sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

		
func player():
	pass

func _physics_process(delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if not is_attacking and ply_alive:
		move_character(dir)
		play_animation(dir)

func move_character(dir: Vector2):
	var current_speed = speed * (attack_speed_multiplier if is_attacking else 1)
	velocity = dir * current_speed
	move_and_slide()

func play_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		sprite.play("idle")
	else:
		if abs(dir.x) > abs(dir.y):
			sprite.flip_h = dir.x < 0
		sprite.play("walk")

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation in ["atk1", "atk2"]:
		is_attacking = false
		sprite.play("idle")

func attack(animation_name: String):
	if is_attacking or not ply_alive:
		return
	is_attacking = true
	sprite.play(animation_name)


func handle_touch_input(action: String):
	pass  
