extends CharacterBody2D

var speed = 50
var health = 100
var dead = false
var playerin_area = false
var player

@onready var sprite = $AnimatedSprite2D
@onready var range_collision = $range/CollisionShape2D  # Get the CollisionShape2D node

func _ready():
	dead = false
	
func _physics_process(delta: float) -> void:
	if !dead:
		range_collision.set_deferred("disabled", false)  # Use set_deferred
		if playerin_area:
			position += (player.position - position) / speed
			sprite.play("atk1")
		else:
			sprite.play("default")
	else:
		range_collision.set_deferred("disabled", true)  # Use set_deferred

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method("player"):  # Ensure this method exists in the player script
		playerin_area = true
		player = body

func _on_range_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		playerin_area = false
		player = null  # Reset player when they leave
