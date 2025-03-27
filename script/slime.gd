extends CharacterBody2D

var speed = 60
var health = 30
var dead = false
var player_in_area = false
var player_inside_hitbox = true  # Track if player is inside hitbox
var player

@onready var sprite = $AnimatedSprite2D
@onready var range_collision = $range/CollisionShape2D

func _ready():
	dead = false


func eny():
	pass

func _physics_process(delta: float) -> void:
	if !dead:
		range_collision.set_deferred("disabled", false)
		if player_in_area and player:
			var direction = (player.position - position).normalized()

			# Prevent glitching: Stop moving if too close
			if position.distance_to(player.position) > 20:  
				velocity = direction * speed  
			else:
				velocity = Vector2.ZERO  

			move_and_slide()
			sprite.play("atk1")
		else:
			velocity = Vector2.ZERO
			sprite.play("default")
	else:
		range_collision.set_deferred("disabled", true)

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body

func _on_range_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		player = null
		

func take_damage(amount: int):
	if player_inside_hitbox:  # Only take damage if player is inside hitbox
		health -= amount
		print(health)
		if health <= 0:
			dead = true  # Mark as dead to prevent movement
			sprite.visible = true
			sprite.modulate.a = 1.0  # Fully visible
			sprite.play("death")
			print("Enemy has 0 health, playing death animation...")

			await sprite.animation_finished  # Wait for animation to finish

			queue_free()  # Now remove the enemy

			
