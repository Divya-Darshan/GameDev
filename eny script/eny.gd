extends CharacterBody2D

const SPEED := 10.0
var player: CharacterBody2D = null
var is_player_in_range: bool = false
var is_player_in_hitbox: bool = false
var is_attacking: bool = false
var touch_controls: Node = null
var _health := 100  # Internal storage

var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, 100)

var is_dead: bool = false 
@export var cur_heath := _health
@onready var slashsfx: AudioStreamPlayer2D = $slashsfx
@onready var deathsfx: AudioStreamPlayer2D = $deathsfx

signal progresseny 

@onready var sprite := $AnimatedSprite2D
@onready var hitbox := $hitbox
@onready var probar := $TextureProgressBar
@onready var tween = get_tree().create_tween()

var fade_duration := 0.3

func _ready():
	probar.visible = false
	touch_controls = get_node('/root/Touchcontrols') # Corrected path!
	if not is_dead and health <= 0:
		sprite.play("death")
		await sprite.animation_finished
		queue_free()
		
	if touch_controls != null:
		touch_controls.button_pressed.connect(_on_touch_controls_button_pressed)
	else:
		printerr("TouchControls autoload not found! Check the autoload list in Project Settings.")

func _on_touch_controls_button_pressed(action_name: String) -> void:
	if is_player_in_hitbox:
		match action_name:
			"attack1":
				sprite.play('hit')
				enytake_damage(5)
			"attack2":
				sprite.play('hit')
				enytake_damage(5)
			_:
				print("Enemy: Unknown button pressed:", action_name)

func enytake_damage(amount: int) -> void:	
	print("Took damage, health:", health)
	if is_dead:
		return  # Skip if already dead

	health -= amount
	progresseny.emit()
	print(health)

	if health == 0:
		
		is_dead = true  # Mark as dead
		velocity = Vector2.ZERO
		sprite.play("death")
		deathsfx.play()
		await sprite.animation_finished
		queue_free()



func _physics_process(delta: float) -> void:
	if is_player_in_range and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
		

		sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
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
	if body.has_method('is_player'):
		is_player_in_hitbox = true
		_show_probar()
		if is_player_in_hitbox:
			for i in range(25):
				if not is_player_in_hitbox:
					break  # Exit the loop if player leaves the hitbox
				body.take_damage(4)
				body.play_hit_animation()
				sprite.play("ack1")
				slashsfx.pitch_scale = randf_range(0.9, 1.2)
				slashsfx.play()
				await get_tree().create_timer(2.0).timeout




func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_in_hitbox = false
		_hide_probar()
		sprite.play("run")




func _show_probar():
	if not probar.visible:
		probar.visible = !probar.visible
		probar.modulate.a = 0.0
		tween = create_tween()
		tween.tween_property(probar, "modulate:a", 1.0, fade_duration)

func _hide_probar():
	tween = create_tween()
	tween.tween_property(probar, "modulate:a", 0.0, fade_duration)
	await tween.finished
	probar.visible = !probar.visible
