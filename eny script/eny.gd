extends CharacterBody2D

const SPEED := 200.0
var health := 100

@onready var touch_controls = get_node("res://control/touchcontrols") # ✅ FIX THIS PATH BASED ON YOUR TREE
@onready var sprite := $AnimatedSprite2D
@onready var tween = get_tree().create_tween()
var fade_duration := 0.3
@onready var hitbox := $hitbox
@onready var probar := $TextureProgressBar
var play_inchase := false
var player = null
var last_pressed_action: String = ""
var player_in_hitbox := false
var is_attacking := false




func _on_button_pressed(action_name: String) -> void:
	print("🕹️ Button pressed:", action_name)
	last_pressed_action = action_name





	if player_in_hitbox and not is_attacking:
		if action_name == "attack1":
			print("Playing ack1 animation!")
		elif action_name == "attack2":
			print("attack2 pressed")
		elif action_name == "inter":
			print("inter pressed")
		elif action_name == "inter2":
			print("inter2 pressed")

func _physics_process(delta: float) -> void:
	if play_inchase and player:
		position += (player.position - position) / SPEED
		sprite.play("run")
		sprite.flip_h = (player.position.x - position.x) < 0
	else:
		sprite.play("default")



func _on_range_body_entered(body: Node2D) -> void:
	player = body
	play_inchase = true

func _on_range_body_exited(body: Node2D) -> void:
	player = null
	play_inchase = false

func is_action_pressed(action_name: String) -> bool:
	return last_pressed_action == action_name

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not probar.visible:
		probar.visible = true
		probar.modulate.a = 0.0
		tween = create_tween()
		tween.tween_property(probar, "modulate:a", 1.0, fade_duration)

	player_in_hitbox = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	tween = create_tween()
	tween.tween_property(probar, "modulate:a", 0.0, fade_duration)
	await tween.finished
	probar.visible = false
	player_in_hitbox = false
	sprite.play("default")
	await sprite.animation_finished
