extends CharacterBody2D
var speed = 95
var player_ch = false
var player = null
var health = 100
var ply_init = false

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	if player_ch:
		position += (player.position - position) /speed  
		anim.play("atk1") 
		if (player.position.x - position.x) < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
	else:
		anim.play("default")
func _ready() -> void:
	anim.play("default")

func slime():
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	player = body
	player_ch = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_ch = false
