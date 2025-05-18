extends CharacterBody2D

const SPEED := 35.0
var player: CharacterBody2D = null
var is_player_in_range: bool = false
var is_player_in_hitbox: bool = false
var is_attacking: bool = false

@onready var sprite := $AnimatedSprite2D
@onready var hitbox := $hitbox
@onready var probar := $TextureProgressBar
@onready var tween = get_tree().create_tween()

var fade_duration := 0.3

func _ready():
	probar.visible = false

func _physics_process(delta: float) -> void:
	if is_player_in_range and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
		

		sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	move_and_slide()

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method('is_player'):
		player = body
		is_player_in_range = true
		sprite.play("run")

func _on_range_body_exited(body: Node2D) -> void:
	
	if body.has_method('is_player') and body == player:
		is_player_in_range = false
		player = null
		sprite.play("default")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_in_hitbox = true
		_show_probar()
		sprite.play("ack1")


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_in_hitbox = false
		_hide_probar()
		sprite.play("run")




func _show_probar():
	if not probar.visible:
		probar.visible = true
		probar.modulate.a = 0.0
		tween = create_tween()
		tween.tween_property(probar, "modulate:a", 1.0, fade_duration)

func _hide_probar():
	tween = create_tween()
	tween.tween_property(probar, "modulate:a", 0.0, fade_duration)
	await tween.finished
	probar.visible = false
