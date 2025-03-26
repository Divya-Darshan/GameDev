extends CharacterBody2D

var speed = 60
var health = 100
var dead = false
var player_in_area = false
var player_inside_hitbox = false  # Track if player is inside hitbox
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
		print(body.name)
		player_in_area = true
		player = body

func _on_range_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		player = null

# Take damage only when attacking inside hitbox
func take_damage(amount: int):
	if player_inside_hitbox:  # Only take damage if player is inside hitbox
		health -= amount
		if health <= 0:
			die()

func die():
	dead = true
	sprite.play("death")
	await sprite.animation_finished
	queue_free()
