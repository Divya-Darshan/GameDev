extends CharacterBody2D

var speed = 95
var player_ch = false
var player = null
var health = 100
var ply_init = false

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	if player_ch and player:
		# Move towards the player only if there is a clear path
		var direction = (player.position - position).normalized()
		
		# Prevent pushing by stopping movement when too close
		if position.distance_to(player.position) > 20:  # Adjust 10 based on your game
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO  # Stop moving when close to the player
		
		anim.play("atk1") 
		anim.flip_h = (player.position.x - position.x) < 0
	else:
		velocity = Vector2.ZERO
		anim.play("default")

	move_and_slide()  # Ensures movement respects physics

func _ready() -> void:
	anim.play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_ch = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_ch = false
