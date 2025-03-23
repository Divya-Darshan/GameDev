extends CharacterBody2D  # Base script for all characters

var speed = 300
var is_attacking = false
var attack_speed_multiplier = 0.1
var ply_alive = true
var ply_health = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

func _ready(): 
	await get_tree().process_frame  
	
	if sprite:
		sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	else:
		print("Error: AnimatedSprite2D not found!")

	if area:
		area.body_entered.connect(_on_pl_hit_body_entered)
		area.body_exited.connect(_on_pl_hit_body_exited)
	else:
		print("Error: Area2D not found!")

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

# Mark the function as `async` to allow `await` to work
func _on_pl_hit_body_entered(body: Node2D):
	if body and body.name == "slime":
		for i in range(10): 
			await get_tree().create_timer(1).timeout
			ply_health -= 10
			
			print(ply_health)
			if ply_health == 0:
				ply_alive = false
				sprite.play("death")
				await get_tree().create_timer(1).timeout
				fade_out_and_remove()  # Fade out and remove player once health reaches 0
				return  # Exit the loop if player is dead



func fade_out_and_remove():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2)  
	await tween.finished
	queue_free()  # Remove the player from the scene after fading out

		
func _on_pl_hit_body_exited(body: Node2D):
	if body:
		pass

func handle_touch_input(action: String):
	pass
