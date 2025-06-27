extends CharacterBody2D

const SPEED := 100.0
var player: CharacterBody2D = null
var is_player_in_range: bool = false
var is_player_in_hitbox: bool = false
var is_attacking: bool = false
var touch_controls: Node = null
var _health := 100

var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, 100)

var is_dead: bool = false
@export var cur_heath := _health
@onready var slashsfx: AudioStreamPlayer2D = $slashsfx

signal progresseny
@onready var shadow: Sprite2D = $Shadow
@onready var col2d: CollisionShape2D = $CollisionShape2D
@onready var sprite := $AnimatedSprite2D
@onready var hitbox := $hitbox
@onready var probar := $TextureProgressBar
@onready var tween = get_tree().create_tween()

var fade_duration := 0.3

func _ready():
	touch_controls = get_node('/root/Touchcontrols')
	if touch_controls != null:
		touch_controls.button_pressed.connect(_on_touch_controls_button_pressed)
	else:
		printerr("TouchControls autoload not found! Check the autoload list in Project Settings.")

func _process(delta: float) -> void:
	if is_dead:
		sprite.visible = false
		queue_free()
		queue_free()

	
	if health == 0 and not is_dead:
		shadow.visible = false
		is_dead = true
		probar.visible = false
		sprite.play("death")
		await sprite.animation_finished
		col2d.disabled = true
		queue_free()
		queue_free()
		queue_free()
		if is_dead:
			sprite.visible = false
			queue_free()
			queue_free()
		


func _on_touch_controls_button_pressed(action_name: String) -> void:
	if is_dead or not is_player_in_hitbox:
		return

	match action_name:
		"attack1":
			enytake_damage(1)
		"attack2":
			enytake_damage(2)
		_:
			print("Enemy: Unknown button pressed:", action_name)

func enytake_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	progresseny.emit()
	print("Took damage, health:", health)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	if is_player_in_range and player:
		velocity = (player.global_position - global_position).normalized() * SPEED if global_position.distance_to(player.global_position) > 40 else Vector2.ZERO
		sprite.flip_h = (player.global_position - global_position).x > 0
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_range_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player = body
		is_player_in_range = true
		sprite.play("run")

func _on_range_body_exited(body: Node2D) -> void:
	if body.has_method("is_player") and body == player:
		is_player_in_range = false
		player = null
		sprite.play("default")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return

	if body.has_method("is_player"):
		is_player_in_hitbox = true
		_show_probar()
		await _play_attack_sequence(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_in_hitbox = false
		_hide_probar()
		sprite.play("run")

func _show_probar():
	pass

func _hide_probar():
	pass

func _play_attack_sequence(target: Node2D) -> void:
	for i in range(25):
		if is_dead or not is_player_in_hitbox:
			break
		target.take_damage(20)
		target.play_hit_animation()
		sprite.play("ack1")
		slashsfx.pitch_scale = randf_range(0.9, 1.2)
		slashsfx.play()
		await get_tree().create_timer(2.0).timeout
